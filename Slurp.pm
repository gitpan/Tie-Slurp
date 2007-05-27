package Tie::Slurp;

use 5.006;
use strict;
use warnings;
use vars qw/$VERSION/;
$VERSION = '0.03';
use Carp;
use Fcntl qw(:DEFAULT :flock);

sub TIESCALAR {
    my ($class, $filename) = @_;
    bless \$filename, $class;
}

sub FETCH {
    sysopen(TieSlurpFile, ${$_[0]}, O_RDONLY)
        or return undef;  # maybe file does not exist

    flock TieSlurpFile, LOCK_SH;

    sysread TieSlurpFile, my $Slurp, -s ${$_[0]};

    close TieSlurpFile;

    $Slurp;
}

sub STORE {
    # Should be changed O_WRONLY shown in the perlopentut to
    # O_RDWR | O_APPEND for Win32 truncate() ? See perlport.
    # While tested under Win2000, O_WRONLY seems to go well,
    # though.

    sysopen(TieSlurpFile, ${$_[0]}, O_WRONLY | O_CREAT)
        or croak "Could not open file '${$_[0]}': $!";

    flock TieSlurpFile, LOCK_EX
        or croak "Could not lock file '${$_[0]}': $!";

    # Beware; you can truncate almost safely while locking
    # but you might lose data on some critical occasions,
    # such as sudden system halt. There is another option
    # (save first and truncate the unwanted part) but VOS
    # is said to support only zero-truncation. In some cases
    # that need no truncation (such as an incremental counter),
    # save-first should be the choice. Generally, truncate-
    # first is more portable.

    truncate TieSlurpFile, 0
        or croak "Could not truncate file '${$_[0]}': $!";

    syswrite TieSlurpFile, $_[1];

    # No need to flock LOCK_UN; closing means unlocking

    close TieSlurpFile;
}

package Tie::Slurp::ReadOnly;

use 5.006;
use strict;
use warnings;
use vars qw/$VERSION/;
$VERSION = '0.02';
use Carp;
use Fcntl qw(:DEFAULT :flock);

sub TIESCALAR {
    my ($class, $filename) = @_;
    bless \$filename, $class;
}

*FETCH = \&Tie::Slurp::FETCH;

sub STORE {
    croak "storing to Tie::Slurp::ReadOnly tied scalar '${$_[0]}' is prohibited"
}

1;
__END__

=head1 NAME

Tie::Slurp - tie a scalar to a named file

=head1 SYNOPSIS

  use Tie::Slurp;
  tie my $template => Tie::Slurp::ReadOnly => 'template';
  tie my $output   => Tie::Slurp => 'output';
  ($output = $template) =~ s/\[(\w+)\]/$data{$1}/g;

=head1 DESCRIPTION

Tie::Slurp associates a scalar with a named file. Read the scalar, the
file is read.  Write to the scalar, the file gets clobbered. C<Flock>
is used for collision avoidance.

Tie::Slurp::ReadOnly works the same as Tie::Slurp, except that C<STORE>
croaks.

=head1 CAVEAT

Though Tie::Slurp does C<flock>, it still has a 'race condition' problem 
in many cases. When you do something to the C<STORE>ed data, the tied
file opens and locks first to C<FETCH>, and closes here once. Then
the C<FETCH>ed data gets changed, and the file opens and locks again
to C<STORE> them. So, if someone access the file while you are changing
your data, something unwanted may happen. Tie::Slurp is useful, but don't
use it under severe conditions.

=head1 AUTHOR

David Nicol, E<lt>davidnico@cpan.orgE<gt>

=head1 CO-MAINTAINER

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 SEE ALSO

L<File::Slurp>

Abigail's comparison of slurping idioms on p5p, October 2003

L<perlopentut>

=head1 LICENSE

GPL/AL

=cut
