#!/usr/bin/perl -w
use strict;
use warnings;
use File::Basename;
use List::Util qw( min max );

my $seqfile = $ARGV[0];
my $adaptorFile = $ARGV[1];

my $minLen = 20;

if ($#ARGV <0){
    die "Usage:  $0 <fastqfile> <adaptorFile>\n";
}


my %adaptors;
open(IN,$adaptorFile);
while(<IN>){
    chomp $_;
    my ($gene,$libID,$adaptor,$stuff) = split(/\,/,$_);
#    print STDERR "Adaptor: $adaptor\n";
#    print STDERR "Gene: $gene\n";
#    print STDERR "libID: $libID\n";
    $adaptors{$adaptor} = "$gene-$libID\t$gene";
#    print STDERR "$adaptor\t$adaptors{$adaptor}\n";
}

open (FQ,$seqfile);
print STDERR "Sequence file: $seqfile\n";
$seqfile =~ s/.fq$//g;
$seqfile =~ s/\_trimmed$//g;
my $lineCount = 5;
my ($header,$seq,$qual,$header2);
my %counts;
foreach my $adapt (keys(%adaptors)){
    $counts{$adapt} = 0;
}

my $lost = 0;
my $adaptorLength = 20;
my $noAdaptor = 1;
while(<FQ>){
    chomp $_;
 #   print STDERR "LC $lineCount\t$_\n";
    if (($_ =~ /^\@/)&& ($lineCount == 5)){ $header = $_; $lineCount = 1; $noAdaptor = 1;}
    elsif (($lineCount == 2)){ $seq = $_;}
    elsif (($lineCount == 3)){ $header2 = $_}
    elsif ($lineCount == 4){ 
	$qual = $_;
	#print STDERR "$qual\n";
	#print STDERR "$header $seq\n";	       
	for (my $i = 0;$i<=(length($seq)-$adaptorLength);$i++){
	    my $possAdapt = substr($seq,$i,$adaptorLength);
#	    print STDERR "possAdapt $possAdapt\n";
	    if (exists($counts{$possAdapt})){
#		print STDERR "Found real Adaptor! $possAdapt $i\n";
		$counts{$possAdapt}++;
		$noAdaptor = 0;
	    } 
	} 
    }
    if ($lineCount ==4 && $noAdaptor == 1){ print STDERR "$header lost\n"; $lost++;} elsif ($lineCount == 4 && $noAdaptor == 0) { print STDERR "$header found!\n";}
    $lineCount++;
}
close(FQ);

print STDERR "$lost Reads could not be assigned to sgRNA.\n";

foreach my $adapt (keys(%adaptors)){
    my $output = "$adaptors{$adapt}\t$counts{$adapt}\n";
    print $output;
}

sub mismatch_count($$) { length( $_[ 0 ] ) - ( ( $_[ 0 ] ^ $_[ 1 ] ) =~ tr[\0][\0] ) }
    