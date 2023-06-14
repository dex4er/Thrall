#!/bin/sh
PERL_THRALL_DEBUG=1 plackup -Ilib -s Thrall -E proxy -MPlack::App::Proxy -e 'enable q{AccessLog}; enable q{Proxy::Connect}; enable q{Proxy::AddVia}; enable q{Proxy::Requests}; Plack::App::Proxy->new->to_app' --workers 50 --max-reqs-per-child 100
