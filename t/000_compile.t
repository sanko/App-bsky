use v5.38;
use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib 'lib', '../lib', 'blib/lib', '../blib/lib';
use App::bsky;
#
ok $App::bsky::VERSION, 'App::bsky::VERSION';
#
done_testing;
