#!/bin/sh

set -e

PERL=${PERL:-perl}

test -x Build && ./Build distclean

$PERL Build.PL

rm -f MANIFEST
pod2markdown < lib/$(grep ^name: MYMETA.yml | sed 's/^name: //; s,-,/,g').pm > README.md

$PERL Build manifest

$PERL Build distdir
diff -u -I^SIGNATURE MANIFEST *-[0-9]*.[0-9]*/MANIFEST

cd *-[0-9]*.[0-9]*

$PERL Build.PL
$PERL Build
$PERL Build test
$PERL -MApp::Prove -e '$app=App::Prove->new; $app->process_args(qw(-Iblib/lib xt)); $app->run;'

$PERL Build distsign
diff -u -I^SIGNATURE MANIFEST *-[0-9]*.[0-9]*/MANIFEST

chmod -R u+w,go-w *-[0-9]*.[0-9]*
tar zcf $(basename $(pwd)).tar.gz *-[0-9]*.[0-9]*

mv *.tar.gz ..
