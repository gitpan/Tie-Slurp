use strict;
use Test::More tests => 10;

# First, make sure we can use Tie::Slurp.
BEGIN { use_ok('Tie::Slurp'); };

#########################

# Then, unlink testfile to clear previous test data.

my $testfile = 'Tie_Slurp_Test.file';

unlink $testfile if -f $testfile;

# Let's tie; this should return success (blessed scalar).

ok(tie(my $First => 'Tie::Slurp' => $testfile)); 

# Try fetch; this should return undef (because $testfile has no data)

ok(!defined $First);

# Let's store new data; $First should have stored data.

my $testvalue = "process$$" x 20;

$First = $testvalue;

# Fetch again; this should return stored value.
ok($First eq $testvalue);

# Store another data. $First should get clobbered.

my $teststr2 = 'shortstring';

$First = $teststr2;

# Fetch again; this should return new data;

ok($First eq $teststr2);

#########################

# Now, let's check ReadOnly mode.

# Tie again; this time we use Tie::Slurp::ReadOnly.
ok(tie(my $RO => 'Tie::Slurp::ReadOnly' => $testfile)); 

# Try fetch; this should return the value $First has saved last.

ok($RO eq $teststr2);

# Then, we are going to exception check.

SKIP: {

  # We need Test::Exception but this isn't a standard module.
  # So check first.
  eval "use Test::Exception";
  skip('without Test::Exception',2) if $@;

  # OK. We have Test::Exception.
  # Let's try to store new data; $RO should croak.

  my $teststr3 = 'should not be stored';

  dies_ok(sub { $RO = $teststr3; }, 'OK. ReadOnly croaks');

  # Fetch again; make sure $RO is not changed.
  ok($RO eq $teststr2);
}

# Lastly, make sure $RO changes if someone else changes the file.

my $teststr4 = 'milkshake';

$First = $teststr4;

ok($RO eq $teststr4);

# All done. Let's clean up.

unlink $testfile;
