use Mojo::Base -strict;
use open ':std', ':encoding(utf8)';

use Test::More;
use Test::Exception;
use Echobot::Robot;

my $actual;
my $robot = Echobot::Robot->new;

$robot->hear(qr/hello/, sub {
    'hello, world';
});
$actual = $robot->respond('hello');
is $actual, 'hello, world';

$robot->hear(qr/こんにちは、((?:\p{InHiragana}|\p{InKatakana}|\p{InCJKunifiedideographs})+)。/, sub {
    my $matches = shift;
    $matches->[1];
});
$actual = $robot->respond('こんにちは、妖精。');
is $actual, '妖精', 'match';

dies_ok { $robot->respond('You can\'t understand this.') };

done_testing;