#!/usr/bin/perl

# This file writed on purpose to crawl
# All links from https://kompas.com provided
# as directory index.
# Muhammad Ghazi Muharam
# Mar 2021

use strict;
use warnings;

# Define constant variable for index builder
use constant TECH_INDEX => 'https://tekno.kompas.com/search/';
use constant FINANCE_INDEX => 'https://money.kompas.com/search/';

# Define module used to crawl website
use WWW::Mechanize ();
my $mech = WWW::Mechanize->new();

# Define module to access localtime
use POSIX qw(strftime);
use Time::Local qw(timegm);
my $multiplier = 0;

# Subroutine to substract date by 1 day
sub date_changer {
    return strftime("%Y-%m-%d", gmtime(timegm(localtime()) - $multiplier * 24*60*60));
}

# Subroutine to build the url of index page
sub index_builder {
    if($_[0] eq "T") {
        return TECH_INDEX . date_changer() . '/' . $_[1];
    }elsif($_[0] eq "M") {
        return FINANCE_INDEX . date_changer() . '/' . $_[1];
    }
}

# Define Configuration of articles to crawl
my $target = 10; # Target url to crawl
my $type = "M"; # T => Techno, M => Money
my $full_type;
my $save_result = 0; # 1 => Save, 0 => Not Save

if($type eq "M"){
    $full_type = "money";
}elsif($type eq "T"){
    $full_type = "tekno";
}

# Define variable to store url to crawl
my %urls;
my $size = 0;

while($size < $target){
    # Define loop Variable
    my $loop = 1;
    my $has_next = 1;
    my $prev_size = $size;

    print("Crawling Article on ". date_changer() .": \n");
    while($has_next) {

        # Building Index Url to crawl
        my $index_to_crawl = index_builder($type, $loop);

        # Get http request to Index Url
        $mech->get($index_to_crawl);
        print("- ". $index_to_crawl. "\n");

        # Get content of crawled Website
        my $page = $mech->content;

        # Access all links in the Url
        my @all_urls = $mech->links();

        # Storing unique link to urls hash
        foreach my $link (@all_urls){
            my $url = $link->url;
            
            if($url =~ 'https:\/\/'.$full_type.'\.kompas\.com\/read\/\d+'){
                $size = keys %urls;
                if($size >= $target){
                    last;
                }

                $urls{$url} = 1;
            }
        }

        if($page =~ 'Next'){
            $loop++;
            $has_next = 1;
        }else{
            $loop = 1;
            $multiplier++;
            $has_next = 0;

            print "Crawled : ". ($size - $prev_size) ." url(s)\nTotal Crawled: ". $size ."\n\n";
        }
    }
}

if($save_result){
    open(FileOutput, '>', 'CrawledURL'.$full_type.'Kompas.txt');
    foreach my $url (keys %urls) {
        print FileOutput "$url\n";
    }
    close FileOutput;
}