use strict;
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'Tie::Slurp',
    'VERSION_FROM'	=> 'Slurp.pm',
    'PREREQ_PM'		=> {},
    ($] >= 5.005 ?
      (ABSTRACT_FROM => 'Slurp.pm', # retrieve abstract from module
       AUTHOR     => 'David Nicol <davidnico@cpan.org>') : ()
    ),
    ($ExtUtils::MakeMaker::VERSION >= 6.31 ?
      (LICENSE => 'perl') : ()
    ),
);
