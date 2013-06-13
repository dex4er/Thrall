package Plack::Handler::Thrall;

use strict;
use warnings;

use threads;
use base qw(Thrall::Server);

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
    $self->{is_multiprocess} = 1;
    $self->{listen_sock} = $listen_sock
        if $listen_sock;
    $self->{max_workers} = $max_workers;
    
    $self;
}

sub run {
    my($self, $app) = @_;
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
            sleep $self->{spawn_interval} if $self->{spawn_interval};
        }
        while (not $self->{term_received}) {
            foreach my $thr (threads->list(threads::joinable)) {
                $thr->join;
                $self->_create_thread($app);
                sleep $self->{spawn_interval} if $self->{spawn_interval};
            }
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

sub _create_thread {
    my ($self, $app) = @_;
    my $thr = threads->create(
        sub {
            my ($self, $app) = @_;
            $self->accept_loop($app, $self->_calc_reqs_per_child());
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
