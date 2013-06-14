package Plack::Handler::Thrall;

use strict;
use warnings;

our $VERSION = '0.01';

use base qw(Thrall::Server);

use threads;

use constant DEBUG => $ENV{PERL_THRALL_DEBUG};

sub new {
    my ($klass, %args) = @_;

    # setup before instantiation
    my $listen_sock;
    my $max_workers = 10;
    for (qw(max_workers workers)) {
        $max_workers = delete $args{$_}
            if defined $args{$_};
    }

    # instantiate and set the variables
    my $self = $klass->SUPER::new(%args);
    $self->{is_multithread} = 1;
    $self->{listen_sock} = $listen_sock
        if $listen_sock;
    $self->{max_workers} = $max_workers;

    $self;
}

sub run {
    my($self, $app) = @_;

    # EV does not work with threads
    $ENV{PERL_ANYEVENT_MODEL} = 'Perl';
    $ENV{PERL_ANYEVENT_IO_MODEL} = 'Perl';

    $self->setup_listener();

    local $SIG{PIPE} = sub { 'IGNORE' };

    if ($self->{max_workers} != 0) {
        local $SIG{TERM} = sub {
            foreach my $thr (threads->list) {
                $thr->kill('TERM')->detach;
            }
            $self->{term_received}++;
        };
        foreach my $n (1 .. $self->{max_workers}) {
            $self->_create_thread($app);
            $self->_sleep($self->{spawn_interval});
        }
        while (not $self->{term_received}) {
            warn "*** running ", scalar threads->list, " threads" if DEBUG;
            foreach my $thr (threads->list(threads::joinable)) {
                warn "*** wait for thread ", $thr->tid if DEBUG;
                $thr->join;
                $self->_create_thread($app);
                $self->_sleep($self->{spawn_interval});
            }
            # slow down main thread
            $self->_sleep($self->{main_thread_delay});
        }
    } else {
        # run directly, mainly for debugging
        local $SIG{TERM} = sub { exit 0; };
        while (1) {
            $self->accept_loop($app, $self->_calc_reqs_per_child());
            sleep $self->{spawn_interval} if $self->{spawn_interval};
        }
    }
}

sub _sleep {
    my ($self, $t) = @_;
    select undef, undef, undef, $t if $t;
}

sub _create_thread {
    my ($self, $app) = @_;
    my $thr = threads->create(
        sub {
            my ($self, $app) = @_;
            warn "*** thread ", threads->tid, " starting" if DEBUG;
            $self->accept_loop($app, $self->_calc_reqs_per_child());
            warn "*** thread ", threads->tid, " ending" if DEBUG;
        },
        $self, $app
    );
}

sub _calc_reqs_per_child {
    my $self = shift;
    my $max = $self->{max_reqs_per_child};
    if (my $min = $self->{min_reqs_per_child}) {
        srand((rand() * 2 ** 30) ^ $$ ^ time);
        return $max - int(($max - $min + 1) * rand);
    } else {
        return $max;
    }
}

1;
