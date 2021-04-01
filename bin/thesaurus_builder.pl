#!/usr/bin/perl

# This file writed on purpose to create thesaurus/dictionary
# base on text data crawled from indonesia news site.
# Muhammad Ghazi Muharam
# Mar 2021

# initalize
use strict;
use warnings;
use Lingua::EN::Bigram;

#Change target to the maximum amount of file participated in creating bigram dictionary
my $TARGET_COUNT = 6000;
#Change tekno to finance to create bigram dictionary of finance article
my $TYPE = "tekno";
my $FILEPATH = "./Cleaned/$TYPE";
my $RESOURCES = "./Resources";
my $OUTPATH = "./Dictionary";

open(FILEOUT, ">", $OUTPATH."/thesaurus-$TYPE.txt") or die $!;

my $ngrams = Lingua::EN::Bigram->new;
my $file_id = 1;

my $string;
my %stopwords;
load_stopwords(\%stopwords);

while( $file_id < $TARGET_COUNT ){
    my $file = $FILEPATH."/$TYPE-$file_id.bersih.dat";
    $string .= read_text( $file );
    $file_id++;
    print "Reading $TYPE-$file_id.bersih.dat\n";
}

$string = stopwords_remover(\%stopwords, lc $string);
$ngrams->text( $string );

# get onegram count
my $onegram_count = $ngrams->word_count;
my $onegram_max = 0;

# get bigram count
my $bigram_count = $ngrams->bigram_count;
my $bigram_max = 0;

# get trigram count
my $trigram_count = $ngrams->trigram_count;
my $trigram_max = 0;

# list the words according to frequency
foreach my $onegram ( sort { $$onegram_count{ $b } <=> $$onegram_count{ $a } } keys %$onegram_count ) {
  if($onegram_max == 0){
      $onegram_max = $$onegram_count{ $onegram }
    }
  print FILEOUT "$$onegram_count{ $onegram }\t$onegram\t".sprintf("%.5f", $$onegram_count{ $onegram }/$onegram_max)."\n";
}

# list the bigrams according to frequency
foreach my $bigram ( sort { $$bigram_count{ $b } <=> $$bigram_count{ $a } } keys %{$bigram_count} ) {
    if($bigram_max == 0){
      $bigram_max = $$bigram_count{ $bigram }
    }

    print FILEOUT "$$bigram_count{ $bigram }\t$bigram\t".sprintf("%.5f", $$bigram_count{ $bigram }/$bigram_max)."\n";
}

# list the trigrams according to frequency
foreach my $trigram ( sort { $$trigram_count{ $b } <=> $$trigram_count{ $a } } keys %$trigram_count ) {
  if($trigram_max == 0){
      $trigram_max = $$trigram_count{ $trigram }
  }
  print FILEOUT "$$trigram_count{ $trigram }\t$trigram\t".sprintf("%.5f", $$trigram_count{ $trigram }/$trigram_max)."\n";
}

close(FILEOUT);

# This function serve the purpose to
# extract text data from cleaned file.
sub read_text{
    # Reading input files 
    open( FH,"<",$_[0] ) or die $!;
    my $string = do { local $/; <FH> };
    $string =~ s/<title>(.*)<\/title>\n<atas>(.*)<atas>\n<tengah>(.*)<tengah>\n<bawah>(.*)<bawah>/$1 $2 $3 $4/gm;
    close( FH );

    return $string;
}

# This function load stopwords into perl hash
# implemented in two-grams.pl by 
# Mr. Taufik Fuadi Abidin.
sub load_stopwords {
  my $hashref = shift;
  open IN, "< $RESOURCES/stopword.txt" or die "Cannot Open File!!!";
  while (<IN>)
  {
    chomp;
    if(!defined $$hashref{$_})
    {
       $$hashref{$_} = 1;
    }
  }  
}

sub stopwords_remover {
  my $str = $_[1];
  foreach my $stopword (keys %{$_[0]}){
    $str =~ s/ +$stopword +/ /g;
    $str =~ s/ +$stopword\./ /g;
    $str =~ s/ +$stopword\,/ /g;
    $str =~ s/\.$stopword +/ /g;
    $str =~ s/\,$stopword +/ /g;
  }
  $str =~ s/[,.?!:;()\-]/ /g; # Remove punctuation
  return $str;
}