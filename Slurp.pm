
package Tie::Slurp;

use 5.006;
no strict;
no warnings;
use vars qw/$VERSION/;
$VERSION = '0.01';
use Carp;
use Fcntl qw(:DEFAULT :flock);

sub TIESCALAR{
	shift;	# lose class name;
	my $filename = shift;
	bless \$filename;
};

sub FETCH{
	unless (
	    sysopen(TieSlurpFile, ${$_[0]}, O_RDONLY)
	){
		return undef;
	};

	flock TieSlurpFile, LOCK_SH;
	sysread TieSlurpFile, my $Slurp, -s ${$_[0]};
	flock TieSlurpFile, LOCK_UN;
	close TieSlurpFile;

	$Slurp;

};
sub STORE{
	unless (
	    sysopen(TieSlurpFile, ${$_[0]}, O_WRONLY | O_CREAT)
	){
		croak "Could not open file '${$_[0]}'";
	};

	flock TieSlurpFile, LOCK_EX;
	# how to truncate and write within an advisory lock:
	# get an exclusive advisory lock on the first FD and
	# use a second FD to truncate and write
	sysopen(TieSlurpFile2, ${$_[0]}, O_WRONLY | O_CREAT | O_TRUNC);
	syswrite TieSlurpFile2, $_[1];
	close TieSlurpFile2;
	flock TieSlurpFile, LOCK_UN;
	close TieSlurpFile;

	undef; # $_[1];

};

package Tie::Slurp::ReadOnly;

use 5.006;
no strict;
no warnings;
use vars qw/$VERSION/;
$VERSION = '0.01';
use Carp;
use Fcntl qw(:DEFAULT :flock);

sub TIESCALAR{
	shift;	# lose class name;
	my $filename = shift;
	bless \$filename;
};

*FETCH = \&Tie::Slurp::FETCH;

sub STORE{
	croak "store to Tie::Slurp::ReadOnly tied scalar '${$_[0]}' prohibited"
};

1;
__END__

=head1 NAME

Tie::Slurp - tie a scalar to a named file

=head1 SYNOPSIS

  use Tie::Slurp;
  tie my $template => Tie::Slurp::ReadOnly => 'template';
  tie my $output => Tie::Slurp => 'output';
  ($output = $template) =~ s/\[(\w+)\]/$data{$1}/g;

=head1 DESCRIPTION

Tie::Slurp associates a scalar with a named file. Read the scalar, the
file is read.  Write to the scalar, the file gets clobbered. C<Flock>
is used for collision avoidance, which is simpler than what is used
by DirDB. As I understand it, recent unices can flock over NFS. To 
avoid getting an empty string by slurping a file during the moment
between when it is opened and truncated for writing and when the lock
is obtained, we open the file twice when we write to it, once to set
up an exclusive lock and once to truncate and write.

Some slurping modules on CPAN don't do any locking at all.

Tie::Slurp::ReadOnly works the same as Tie::Slurp, except that STORE
croaks.


=head2 EXPORT

None by default.

=head1 HISTORY

=over 8

=item 0.01

sysread, syswrite, flock.

=back

=head1 AUTHOR

David Nicol, E<lt>davidnico@cpan.orgE<gt>

=head1 SEE ALSO

File::Slurp
Abigail's comparison of slurping idioms on p5p, October 2003
DirDB module

=cut
