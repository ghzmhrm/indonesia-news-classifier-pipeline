#!/usr/bin/perl

# This file writed on purpose to build the
# feature of each document presented in Cleaned
# Folder.
# Muhammad Ghazi Muharam
# Mar 2021

use strict;
use warnings;
use Lingua::EN::Bigram;
use FileHandle;
use POSIX qw(ceil);

# Using local module
use Cwd qw(abs_path);
use FindBin;
use lib abs_path("$FindBin::Bin/../lib");
use TextPreprocess;

# Defining the threshold to be used to
my $THRESHOLD = "0.6";
my @types = ("tekno", "finance");

# Defining ngrams lingua module
my $ngrams = Lingua::EN::Bigram->new;

# Create hash of stopwords base on Resources/stopword.txt
my %stopwords;
TextPreprocess::load_stopwords( \%stopwords );

# Create hash of thesaurus based on the threshold
print "Reading Thesaurus Tekno\n";
my ($t_tekno, $t_tekno_count) = TextPreprocess::read_thesaurus("tekno", $THRESHOLD);
my %thesaurus_tekno = %$t_tekno;

print "Reading Thesaurus Finance\n";
my ($t_finance, $t_finance_count) = TextPreprocess::read_thesaurus("finance", $THRESHOLD);
my %thesaurus_finance = %$t_finance;

# Define an out file (.csv)
open(FILEOUT, ">", "./Dataset/data-$THRESHOLD.csv");

# Create csv title columns
my @columns = qw/title_1a title_2a title_3a title_1b title_2b title_3b atas_1a atas_2a atas_3a atas_1b atas_2b atas_3b tengah_1a tengah_2a tengah_3a tengah_1b tengah_2b tengah_3b bawah_1a bawah_2a bawah_3a bawah_1b bawah_2b bawah_3b label/;
print FILEOUT join(',', @columns), "\n";

# Looping through types ("tekno", "finance")
for my $type (@types){
    # Reading all of file name to get the number of files
    my @files = glob("./Cleaned/$type/*");
    my $file_number = 1;
    for my $file(@files){
        # Override the file name to sort the filename better
        my $file = "./Cleaned/$type/$type-$file_number.bersih.dat";

        # Calling TextPreprocess method to read text from file
        # Check the ../lib/TextPreprocess file for better 
        # documentation
        my @contents = &TextPreprocess::read_text($file);
        my @all_features;

        # Outputting the filename currently processing
        if ( file_number % 20 == 0 ){
            print "Building Feature from $file\n";
        }

        # Looping through the entire content returned from 
        # TextPreprocess::read_text method
        for my $content ( @contents ){
            my $string = TextPreprocess::stopwords_remover(\%stopwords, lc $content);

            $ngrams->text( $string );

            # Building feature
            my @features = TextPreprocess::feature_constructor(\%thesaurus_tekno, $ngrams);
            push(@all_features, @features);

            @features = TextPreprocess::feature_constructor(\%thesaurus_finance, $ngrams);
            push(@all_features, @features);
        }
        # Outputting the entire features as a single line
        print FILEOUT join(',', @all_features),",$type\n";
        $file_number++;
    }
}

close(FILEOUT);