#!/usr/bin/perl
# PODNAME: prereqs.pl
# ABSTRACT: print prereqs from META.json etc.
use strict;
use warnings;
use CLI::Tiny qw (error say verbose);
use Getopt::Long;
use CPAN::Meta::Prereqs::Extract;

my %opts;
my @filter;
GetOptions(
	'list'     => \$opts{list},
	'verbose'  => \$CLI::Tiny::verbose,
	'filter=s' => \@filter
);

foreach my $default (qw (META.json META.yml)) {
	if ( -f $default ) {
		$ARGV[0] ||= $default;
	}
}

if ( !$ARGV[0] ) {
	error "No Meta file found";
}

if ( !-f $ARGV[0] ) {
	error "File not found: $ARGV[0]";
}

verbose "About to load $ARGV[0]";

my $tractor =
  new CPAN::Meta::Prereqs::Extract( verbose => $CLI::Tiny::verbose );
$tractor->load_meta( file => $ARGV[0] );
$tractor->process(@filter);
if ( $opts{list} ) {
	$tractor->list;
	exit 1;
}
$tractor->print_prereqs();

exit 1;

=head1 SYNOPSIS

	prereqs.pl | cpanm
	prereqs.pl somefile.yml | cpanm
	prereqs.pl --list

=head1 DESCRIPTION

Print the requires from yaml or json file.

=head1 OPTIONS

--list list phases, relationships and version numbers

--verbose be more verbose

=head1 SEE ALSO

L<CPAN::Meta>, L<App::cpanminus>

=head1 TODO

* write tests

* should I allow an option to print only those modules which are not 
  installed? Doesn't seem essential.

=cut
