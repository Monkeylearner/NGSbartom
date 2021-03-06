#!/opt/local/bin/perl -w

use strict;

if($#ARGV < 0) {
  print $#ARGV;
  print STDERR "Useage: $0 < max kmer length > < inputList >\n";
  exit;
}

my $k = $ARGV[0];
my $listfile = $ARGV[1];

my @alphabet = ("A","C","G","T");
#print "$k @alphabet\n";

my @kmerlist = @alphabet;
for (my $i = 1; $i < $k; $i++) {
#  print "$i\n";
  my @newlist;
  foreach my $word (@kmerlist){
    foreach my $letter (@alphabet){
      my $newWord = $word.$letter;
      #      print "$word + $letter = $newWord\n";
      push (@newlist, $newWord);
    }
  }
#  @kmerlist = @newlist;
  push(@kmerlist,@newlist);
}
print STDERR "Kmers @kmerlist\n";
my @cleanList;
my %seen;

foreach my $kmer (@kmerlist){
  if ($kmer ne ""){
    if (!exists($seen{$kmer})){
      push(@cleanList,$kmer);
      $seen{$kmer} = 1;
    }
  }
}
@kmerlist = @cleanList;
print STDERR "KmersClean @kmerlist\n";

my $string = "";
open(IN,$listfile);
while(<IN>){
    chomp $_;
    $_ =~ s/\r\n/\n/g;
    $_ =~ s/\r//g;
    if (($_ =~ /^\dmer/) || ($_ =~ /^Sequence/)){
	chomp $_;
	print $_;
	print "\tLength";
	foreach my $kmer (@kmerlist){
	    print "\t$kmer";
	}
	print "\n";
    } elsif ($_ =~ /^([ACTGN]+)\s/){
	chomp $_;
	print $_;
	$string = $1;
	print "\t".length($string);
	foreach my $kmer (@kmerlist){
	    #      my $kmercount = ($string =~ tr/$kmer//);
#	    my $kmercount = () = $string =~ /$kmer/g;
	    my $kmercount = () = $string =~ /(?=\Q$kmer\E)/g;
	    my $ratio = $kmercount/((length($string)-length($kmer)+1));
	    #      print "\t$string:$kmer:$kmercount:$ratio";
	    print "\t$ratio";
	}
	print "\n";
    }
}

