package CPAN::Meta::Prereqs::Extract;
# ABSTRACT: Several ways of getting prereqs out of meta.

use strict;
use warnings;
use Moose;

=head1 SYNOPSIS

	use CPAN::Meta::Prereqs::Extract;
 	my $tractor=new CPAN::Meta::Prereqs::Extract();
	$prereqs=$tractor->YMLfile ($metaFile);
	$prereqs=$tractor->JSONfile ($metaFile);
	$prereqs=$tractor->cpan ($metaFile);
	
	#$prereqs is hashref
	
=cut



 


1;