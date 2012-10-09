#!/usr/bin/perl
# PODNAME: prereqs.pl
# ABSTRACT: print prereqs from META.json etc.
use strict;
use warnings;
use CLI::Tiny qw (error say verbose);
use Getopt::Long;
use CPAN::Meta;

my %opts;
my @filter;
GetOptions(
	'list'    => \$opts{list},
	'verbose' => \$CLI::Tiny::verbose,
	'filter=s' => \@filter
);

my @def = qw (META.json META.yml);
foreach my $default (@def) {
	if ( -f $default ) {
		$ARGV[0] ||= $default;
	}
}

if ( !-f $ARGV[0] ) {
	error "File not found: $ARGV[0]";
}

verbose "About to load $ARGV[0]";

my $meta;
if ( $ARGV[0] =~ /\.yml$/ ) {
	local $/;
	open( my $fh, '<', $ARGV[0] ) or die "Can't open file $ARGV[0]";
	$meta = CPAN::Meta->load_yaml_string(<$fh>);
	close $fh

}
else {
	$meta = CPAN::Meta->load_file( $ARGV[0] );
}

my $prereqs=process($meta, @filter) or die "Can't process meta";
list($prereqs) if ( $opts{list} );
print_prereqs($prereqs);
exit 1;


#
## SUBS
#


=func my $prereqs=process ($meta, @filter);

Returns prereqs as string hash. If @filter contains phases, they are left out.

Warns when filters don't exist only in verbose mode.

=cut

sub process {
	my $meta = shift || return;
	
	$prereqs = $meta->effective_prereqs->as_string_hash;

	foreach my $filter (@_) {
		if ($prereqs->{$filter}) {
			delete $prereqs->{$filter};
		} else {
			verbose "Filter '$filter' doesn't exist";
		}
	}

	return $prereqs;
}

=func print_prereqs ($prereqs);

prints prereqs package names only to STDOUT 

=cut

sub print_prereqs {
	my $prereqs = shift || return;

	foreach my $phase ( keys %{$prereqs} ) {
		foreach my $rel ( keys %{ $meta->{prereqs}{$phase} } ) {
			next if $rel eq 'conflicts';
			foreach my $mod ( keys %{ $meta->{prereqs}{$phase}{$rel} } ) {
				print "$mod ";
			}
		}
	}
	print "\n";

}

=func list ($processed)

Prints prereqs from Meta file to STDOUT in a readable format 

TODO: Should I warn when phase is develop?

=cut


sub list {
	my $prereqs = shift || return;

	foreach my $phase ( keys %{$prereqs} ) {
		my $indent = ' ';
		say "$phase";
		foreach my $rel ( keys %{ $meta->{prereqs}{$phase} } ) {
			say "$indent$rel";
			foreach my $mod ( keys %{ $meta->{prereqs}{$phase}{$rel} } ) {
				say "$indent$indent$mod "
				  . $meta->{prereqs}{$phase}{$rel}{$mod};
			}
		}

	}
	exit 0;
}

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
