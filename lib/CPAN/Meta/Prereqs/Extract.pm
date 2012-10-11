package CPAN::Meta::Prereqs::Extract;
{
  $CPAN::Meta::Prereqs::Extract::VERSION = '0.002';
}

#ABSTRACT: print prereqs from META.json etc.

use strict;
use warnings;
use CPAN::Meta;
use CLI::Tiny qw (error say);
use Moose;    #overkill

has 'verbose'  => ( is => 'ro', isa => 'Int' );
has 'file'     => ( is => 'rw', isa => 'Str' );
has 'cpanmeta' => ( is => 'rw', isa => 'Object' );
has 'prereqs'  => ( is => 'rw', isa => 'HashRef' );
has 'filter'   => ( is => 'rw', isa => 'Array' );


#
## SUBS
#


sub BUILD {
	my $self=shift;
	if ($self->file) {
		$self->load_meta;
	}
	
}


sub load_meta {
	my $self = shift;
	my %args = @_;
	my $file=$args{file}|| $self->file; # arg overrides $self if both are given.

	return if (!$file);

	if ( $file =~ /\.yml$/ ) {
		local $/;
		open( my $fh, '<', $file ) or die "Can't open file $file";
		$self->cpanmeta( CPAN::Meta->load_yaml_string(<$fh>) );
		close $fh;
	}
	else {
		$self->cpanmeta( CPAN::Meta->load_file( $file ) );
	}

	return $self->cpanmeta;
}


sub process {
	my $self = shift;
	my @filter=$self->filter||@_;

	if ( !$self->cpanmeta ) {
		die "Some error";
	}

	$self->{prereqs} = $self->cpanmeta->effective_prereqs->as_string_hash;

	foreach my $filter (@filter) {
		if ( $self->{prereqs}->{$filter} ) {
			delete $self->{prereqs}->{$filter};
		}
		else {
			print "Filter '$filter' doesn't exist" if $self->verbose;
		}
	}

	#$self->cpanmeta (undef);
	return $self->prereqs;
}


sub print_prereqs {
	my $self = shift;
	if ( !$self->prereqs ) {
		die "some error message";
	}

	foreach my $phase ( keys %{ $self->prereqs } ) {
		foreach my $rel ( keys %{ $self->prereqs->{$phase} } ) {
			next if $rel eq 'conflicts';
			foreach my $mod ( keys %{ $self->prereqs->{$phase}{$rel} } ) {
				print "$mod ";
			}
		}
	}
	print "\n";

}


sub list {
	my $self = shift;
	if ( !$self->prereqs ) {
		die "some error message";
	}

	foreach my $phase ( keys %{ $self->prereqs } ) {
		my $indent = ' ';
		say "$phase";
		foreach my $rel ( keys %{ $self->prereqs->{$phase} } ) {
			say "$indent$rel";
			foreach my $mod ( keys %{ $self->prereqs->{$phase}{$rel} } ) {
				say "$indent$indent$mod "
				  . $self->prereqs->{$phase}{$rel}{$mod};
			}
		}

	}
}

1;

__END__
=pod

=head1 NAME

CPAN::Meta::Prereqs::Extract - print prereqs from META.json etc.

=head1 VERSION

version 0.002

=head1 SYNOPSIS

	use CPAN::Meta::Prereqs:Extract;
	my $tractor=new CPAN::Meta::Prereqs:Extract (file=>'META.json', verbose=>1);

	$tractor->process(@filter);
	if ( $opts{list} ) {
		$tractor->list;
	exit 1;
}
$tractor->print_prereqs();

=head1 METHODS

=head2 my $meta=$tractor->load_meta([$file]);

Either hand over $file via parameter or set it during new. Parameter overwrites
object.

Return value is a CPAN::Meta object.

=head2 $tractor->process (@filter);

Expects meta in $self->meta. Sets $self->prereqs and also returns them as string hash. 

If @filter contains phases, they are left out.

Warns when filters don't exist only in verbose mode.

=head2 $tractor->print_prereqs;

prints prereqs package names only to STDOUT 

=head2 $tractor->list;

Prints prereqs from Meta file to STDOUT in a readable format 

TODO: Should I warn when phase is develop?

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

