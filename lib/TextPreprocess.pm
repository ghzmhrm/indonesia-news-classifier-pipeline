#!/usr/bin/perl

# Perl module to preprocess text
# into feature.
# Muhammad Ghazi Muharam
# Mar 2021

package TextPreprocess;
# TextPreprocess.pm

use strict;
use warnings;

my $LEVEL = 1; # default log level

# Default Path Location of the Project
my $PATH_DICTIONARY = "./Dictionary";
my $PATH_DICTIONARY_TEKNO = $PATH_DICTIONARY."/thesaurus-tekno";
my $PATH_DICTIONARY_FINANCE = $PATH_DICTIONARY."/thesaurus-finance";
my $PATH_RESOURCES = "./Resources";

# Subroutine to load stopwords into perl hash
# implemented in two-grams.pl by 
# Mr. Taufik Fuadi Abidin.
# Call e.g
#   load_stopwords(\%stopwords);
# Arguments:
#   \%stopwords: reference of hash to populate
# Return:
#   -
sub load_stopwords {
    my $hashref = shift;
    
    # Reading stopwords from stopword.txt
    open IN, "< $PATH_RESOURCES/stopword.txt" or die "Cannot Open File!!!";
    
    while (<IN>)
    {
        chomp;
        if(!defined $$hashref{$_})
        {
            $$hashref{$_} = 1;
        }
    }  
}

# Subroutine to remove stopword appearance in provided string
# Call e.g : 
#   $string = stopwords_remover(\%stopwords, lc $string)
# 
# Arguments:
#   \%stopwords: reference of populated stopwords hash
#   $string: string to remove the stopwords from
#
# Return:
#   Cleaned $string
sub stopwords_remover {
    my $stopwords = $_[0];
    my $str = $_[1];
    foreach my $stopword (keys %{$stopwords}){
        $str =~ s/ +$stopword +/ /g;
        $str =~ s/ +$stopword\./ /g;
        $str =~ s/ +$stopword\,/ /g;
        $str =~ s/\.$stopword +/ /g;
        $str =~ s/\,$stopword +/ /g;
    }
    $str =~ s/[,.?!:;()\-]/ /g; # Remove punctuation
    return $str;
}

# Subroutine to read thesaurus from default Path
# Call e.g:
#   ($t_tekno, $t_tekno_count) = read_thesaurus("tekno", 0.4);
# 
# Arguments:
#   Arguments 1: "tekno" or "finance"
#   Arguments 2: 0.4 or 0.6
#
# Return:
#   \%thesaurus: hash reference of thesaurus with normalized value
#   \%thesaurus_count: hash reference of thesaurus with word count value
sub read_thesaurus {
    my %thesaurus;
    my %thesaurus_count;
    my $type = $_[0];
    my $threshold = $_[1];
    
    if($type eq "tekno"){
        open(FH, "<", "$PATH_DICTIONARY_TEKNO-$threshold.txt") or die $!;
    }elsif($type eq "finance"){
        open(FH, "<", "$PATH_DICTIONARY_FINANCE-$threshold.txt") or die $!;
    }

    while(my $line = <FH>){
        my ($count, $grams, $normalized) = split("\t", $line);
        $thesaurus{$grams} = $normalized;
        $thesaurus_count{$grams} = $count;
    }
    close FH;

    # returning multiple values using array
    return (\%thesaurus, \%thesaurus_count);
}

# Subroutine to extract text data from cleaned file
# Call e.g:
#   ($title, $atas, $tengah, $bawah) = read_text($file);
# 
# Arguments:
#   $file: Path to file
#
# Return:
#   $1 Title of the page
#   $2 Top Content of the page
#   $3 Middle Content of the page
#   $4 Bottom Content of the page
sub read_text {
    my $file = $_[0];
    # Reading input files 
    open( FH,"<",$file ) or die $!;
    my $string = do { local $/; <FH> };
    $string =~ /<title>(.*)<\/title>\n<atas>(.*)<atas>\n<tengah>(.*)<tengah>\n<bawah>(.*)<bawah>/;
    
    close( FH );
    my @contents = ($1, $2, $3, $4);
    return @contents;
}

# Subroutine to build feature from document 
# Call e.g:
#   TextPreprocess::feature_constructor(\%thesaurus_tekno, $ngrams);
# 
# Arguments:
#   \%thesaurus_tekno: Reference of hash thesaurus
#   $ngrams: object of Lingua::EN::Bigram
#
# Return:
#   @features calculated feature from ngrams
sub feature_constructor {
    my $thesaurus= $_[0];
    my $ngrams = $_[1];

    # get onegram count
    my $onegram_count = $ngrams->word_count;
    my $onegram_size = keys %$onegram_count;

    # get bigram count
    my $bigram_count = $ngrams->bigram_count;
    my $bigram_size = keys %$bigram_count;

    # get trigram count
    my $trigram_count = $ngrams->trigram_count;
    my $trigram_size = keys %$trigram_count;

    my @ngrams = ($onegram_count, $bigram_count, $trigram_count);

    my @features;
    for my $ngram (@ngrams){
        if (keys %$ngram != 0)
        {
            push @features, word_counter($thesaurus, $ngram)/keys %$ngram;
        }
        else
        {
            push @features, 0;
        }
    }

    return @features;
}

# Subroutine to count ngrams word exist in thesaurus
# Call e.g:
#   word_counter($thesaurus, $ngram)/keys %$ngram;
# 
# Arguments:
#   $thesaurus: Reference of hash thesaurus
#   $ngram: object of Lingua::EN::Bigram
#
# Return:
#   $counter number of world exist in thesaurus
sub word_counter {
    my $thesaurus = $_[0];
    my $ngrams_count = $_[1];

    my $counter = 0;
    foreach my $gram ( keys %$ngrams_count ) {
        if ( exists $$thesaurus{ $gram } )
        {
            $counter++;
        }
    }
    return $counter;
}

1;

