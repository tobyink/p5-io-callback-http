use 5.008008;
use strict;

use lib "lib";
use lib "t/lib";

use Test::More tests => 4;
use Test::HTTP::Server;
use HTTP::Request::Common qw(POST);
use IO::Callback::HTTP;

my $server = Test::HTTP::Server::->new;

my $fh = IO::Callback::HTTP::->new('<', $server->uri.'echo');

if (eval "use IO::Detect; 1")
{
	ok($fh->IO::Detect::is_filehandle, '$fh detected as a file handle');
}
else
{
	ok(1, 'dummy');
}

like(
	scalar <$fh>,
	qr{^GET /echo HTTP/1.[01]}i,
	'first line seems fine',
);

my $fh2 = IO::Callback::HTTP::->new('<', POST(
	$server->uri.'echo',
	Here_It_Is => 'Oh Yeah',
));

like(
	scalar <$fh2>,
	qr{^POST /echo HTTP/1.[01]}i,
	'first line seems fine',
);

my $found_it;
while (<$fh2>) { $found_it++ if m{Here-It-Is}i };

is($found_it => 1, 'another lines seems fine');
