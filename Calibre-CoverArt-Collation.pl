#!/usr/bin/env perl
# template script with embedded documentation and command parsing

use strict;
use warnings;
use v5.10; #make use of the say command and other nifty perl 10.0 onwards goodness
use Carp;
use File::Basename;
use File::Spec;
use File::Find::Rule;


#set the version number in a way Getopt::Euclid can parse
BEGIN { use version; our $VERSION = qv('0.1.1_1') }

use Getopt::Euclid; # Create a command-line parser that implements the documentation below... 

my $destination = $ARGV{-d};
my $calibreLibrary = $ARGV{-c};
           
unless ( defined($destination) || defined($calibreLibrary) )
{ croak "Need both -c and -d defined for use.  Try with --man to see options"; }

#TODO add test for directories existing

# lookup all the files below $calibreLibrary
my @files = File::Find::Rule->file
	->name('cover.jpg')
	->in($calibreLibrary);

my $cover;

foreach $cover (@files)
{
	my ($name,$path,$suffix) = fileparse($cover);
	#my @dirs = File::Spec->splitdir( $path);
	$path =~ m/^.*\/(.*)\ \(.*\/$/x;
	#say $cover;
	say $1;
}

#TODO strip out whitespace and commas etc

__END__
=head1 NAME

Calibre-CoverArt-Collation.pl - script to assemble all eBook covers in one dir as unique images



=head1 USAGE

    Calibre-CoverArt-Collation.pl [-d -c] 

=head1 OPTIONS

=over

=item  -d[estination] [=] <destination>

Specify destination directory to select the file from [default: destination.default]
Defaults to './'


=for Euclid:
    destination.type:    string 
    destination.default: './'
    destination.type.error: must be a valid directory

=item  -c[alibre] [=] <calibre>

Specify calibre library directory [default: calibre.default]

=for Euclid:
    calibre.type:    string
    calibre.type.error: must be a valid directory

=item –v

=item --verbose

Print all warnings

=item --version

=item --usage

=item --help

=item --man

Scans a user provided (-c) directory for jpeg's and copies them to

=back

=begin remainder of documentation here. . .
