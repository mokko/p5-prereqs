#!/usr/bin/perl
# ABSTRACT: print prereqs from META.json etc.
use strict;
use warnings;
use CLI::Tiny qw (error say verbose);
use Getopt::Long;
#use Module::Loader;    #what happened to this module? It's no longer on cpan...
use CPAN::Meta;

our @yaml_phases = qw (build_requires configure_requires requires recommends);

my %opts;
GetOptions(
	'list'    => \$opts{list},
	'verbose' => \$opts{verbose},
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
if ( $opts{verbose} ) { CLI::Tiny::verbose_on; }
verbose "About to load $ARGV[0]";

my $meta = CPAN::Meta->load_file($ARGV[0]);


#for my $module ($prereqs->required_modules) {
#    my $version = get_local_version($module);
#
#    die "missing required module $module" unless defined $version;
#    die "version for $module not in range"
#      unless $prereqs->accepts_module($module, $version);
#  }

my $meta;
if ( $ARGV[0] =~ /\.json$/ ) {
	load_module 'JSON';
	local $/;
	open( my $fh, '<', $ARGV[0] ) or die "Can't open file $ARGV[0]";

	$meta = eval { decode_json(<$fh>); };
	close $fh;
	die $@ if $@;
	list_json($meta) if ( $opts{list} );
	print_json($meta);
}
elsif ( $ARGV[0] =~ /\.yml$/ ) {
	load_module 'YAML::Any' => qw/LoadFile/;
	$meta = LoadFile( $ARGV[0] );

	#say Dumper $meta;
	list_yaml($meta) if ( $opts{list} );
	print_yaml($meta);
}
else {
	error "Unrecognized file format $ARGV[0]";
}

#
## SUBS
#

#should I warn when phase is develop?
sub print_json {
	my $meta = shift || die "Internal error: Need list!";
	foreach my $phase ( keys %{ $meta->{prereqs} } ) {
		foreach my $rel ( keys %{ $meta->{prereqs}{$phase} } ) {
			next if $rel eq 'conflicts';
			foreach my $mod ( keys %{ $meta->{prereqs}{$phase}{$rel} } ) {
				print "$mod ";
			}
		}
	}
	print "\n";
}

sub print_yaml {
	my $meta = shift || die "Internal error: Need list!";
	foreach my $phase (@yaml_phases) {
		foreach my $mod ( keys %{ $meta->{$phase} } ) {
			print "$mod ";
		}
	}
	print "\n";
}

sub list_json {
	my $meta = shift || die "Internal error: Need list!";
	foreach my $phase ( keys %{ $meta->{prereqs} } ) {
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

sub list_yaml {
	my $meta = shift || die "Internal error: Need list!";
	foreach my $phase (@yaml_phases) {
		my $indent = ' ';
		say "$phase";
		foreach my $mod ( keys %{ $meta->{$phase} } ) {
			say "$indent$mod " . $meta->{$phase}{$mod};
		}
	}

	exit 0;
}


=head1 SYNOPSIS

	prereqs.pl | cpanm
	prereqs.pl somefile.yml | cpanm

=head1 DESCRIPTION

Print the requires from yaml or json file.

=head1 OPTIONS

--list list phases, relationships and version numbers

=head1 SEE ALSO

L<CPAN::Meta>, L<App::cpanminus>

=head1 TODO

allow picking phases and modes
deal with version numbers
write tests

=cut
