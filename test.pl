# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 10 };
use Tie::Slurp;
ok(1); # If we made it this far, we're ok.

#########################

unlink "Tie_Slurp_Test.file";

# tie returns success
ok(tie my $First => Tie::Slurp => "Tie_Slurp_Test.file"); 

#initially undefined
ok($First,undef);

# store returns stored value (no it doesn't -- submitted a docpatch)
$First="process$$"x20;

# fetch returns stored value
ok($First,"process$$"x20);

# store truncates
$First = 1;
ok($First, 1);


# RO tie returns success
ok(tie my $RO => Tie::Slurp::ReadOnly => "Tie_Slurp_Test.file"); 

# file the same as we left it
ok($RO,1);

# RO store croaks
eval {$RO='cheeseburger'};
ok($@ and print "$@\n");

# and RO is unchanged
ok(1,$RO);

# until it is changed
$First = 'milkshake';
ok($RO,'milkshake');


