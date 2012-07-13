use 5.008008;
use strict;

use lib "lib";
use lib "t/lib";

use Test::More tests => 4;
use Test::HTTP::Server;
use HTTP::Request::Common qw(POST);
use IO::Callback::HTTP;

my $server = Test::HTTP::Server::->new;

my $fh = IO::Callback::HTTP::->new(
	'>',
	$server->uri.'echo',
	success => \&success,
);

if (eval "use IO::Detect; 1")
{
	ok($fh->IO::Detect::is_filehandle, '$fh detected as a file handle');
}
else
{
	ok(1, 'dummy');
}

sub success
{
	like(
		shift->decoded_content,
		qr{^PUT /echo HTTP/1.[01]}i,
		'first line seems fine',
	);
}

my $fh2 = IO::Callback::HTTP::->new(
	'>',
	POST(
		$server->uri.'echo',
		Content_Type => 'text/plain',
	),
	success => \&success2,
);

sub success2
{
	my $x = shift;
	
	like(
		$x->decoded_content,
		qr{^POST /echo HTTP/1.[01]}i,
		'first line seems fine',
	);

	like(
		$x->decoded_content,
		qr{Hello World}i,
		'got body content',
	);
}

print $fh 'Hello World';
print $fh2 'Hello World';
close $fh;
close $fh2;