#!/usr/bin/perl

# This file writed on purpose to clean
# The entire Download Folder.
# Muhammad Ghazi Muharam
# Mar 2021

use warnings;
use strict;
use Mojo::DOM;
use Mojo::File;
use Array::Split qw( split_into split_by );
use Try::Catch;
use POSIX;

# Function to clean text
sub clean_text{
    my $str = shift;
    $str =~ s/^\s+|\s+$//g; # Trim string
    $str =~ s/KOMPAS\.com - *//g; # Remove article open template KOMPAS.COM
    $str =~ s/Baca juga\: ?(.+?)[,.\n\r]//g; # Remove recommendation article in text
    $str =~ s/\r?\n|\r//g; # Remove new line
    $str =~ s/[^!-~\s] ?/ /g; # Make sure all string are ascii characters
    $str =~ s/ +/ /g; # Removing multiple whitescpaces
    $str =~ s/[^[:ascii:]]//g; # Remove non ascii character
    $str =~ s/\.(\w?)/. $1/g; # Add Space to non structed article
    return $str; # return cleaned text
}

sub text_extractor{
    # Setting up output directory
    my $OUTPUT_DIR = "./Cleaned/$_[0]/";
    mkdir $OUTPUT_DIR;
    # Opening html file
    my $file = Mojo::File->new("./Download/$_[0]/", $_[1].'.html');

    # Parse html file
    my $dom = Mojo::DOM->new($file->slurp);

    my $title;
    try {
        # Get Title of the articles
        $title = $dom->at('title')->text;
        $title =~ s/ Halaman all - Kompas.com//g;
    } catch {};

    if (!defined($title)) {
        return;
    }

    # Opening file output and write title tag
    open(FileOutput, '>', "$OUTPUT_DIR/$_[1].bersih.dat");
    print FileOutput "<title>$title</title>\n";

    try {
        # Remove sub article title
        $dom->at('.read__content')->at('h2')->remove;
        $dom->at('.read__content')->at('h2')->at('strong')->remove;
    } catch {};
    
    # Get all text inside read__content class (Article content)
    my $str = clean_text($dom->at('.read__content')->all_text);
    my @content = split "\n", $str;

    if (@content <= 6){
        @content = split(/(?<=\. )/, $str);
    }

    # Define loop variable
    my @tags = ('atas', 'tengah', 'bawah');
    my $loop = 0;

    # Split @content array into 3 evenly divided array
    my @splitted_content = split_into(3, @content);

    # Write each array into output file
    foreach $str (@splitted_content){
        print FileOutput "<$tags[$loop]>@{$str}<$tags[$loop]>\n";
        $loop++;
    }

    close FileOutput;
}

my @categories = ('tekno', 'finance');

# Looping through the entire category 
foreach my $category ( @categories ){
    my @files = split "\n", `ls ./Download/$category`;

    # Looping through the entire files
    foreach my $file (@files){
        print "Cleaning $file \n";
        text_extractor($category, (split /\./, $file)[0]);
    }
}