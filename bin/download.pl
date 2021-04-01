#!/usr/bin/perl

# use strict;
# use warnings;

# Define output directory
my $OUTPUT_DIR = './Download/finance';

# Handle Command Line Parameters
if (@ARGV < 2){
    print "Url File or Category doesn't provided\n";
    exit;
}

# Parameters variable
my $filename = $ARGV[0];
my $category = $ARGV[1];
my $fullpath = $OUTPUT_DIR;
# Open file provided in Parameters
open(url_file, '<', $filename) or die $!;

my $y = 1;
mkdir $OUTPUT_DIR;

while(my $url = <url_file>){
    chomp($url);
    $url .= '?page=all';
    
    `wget -nv -O $fullpath/$category-$y.html $url `;
    $y++;
    
    if($y % 25 == 0){
        sleep(rand(5))
    }
}


