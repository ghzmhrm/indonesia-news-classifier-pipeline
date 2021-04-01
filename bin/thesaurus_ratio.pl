#!/usr/bin/perl

# This file writed on purpose to build the
# final form of thesaurus 
# Muhammad Ghazi Muharam
# Mar 2021

use strict; 
use warnings;

my $threshold = 0.6;
# Uncomment line below to run the debugger
# my $string_debugger = "google";


# Subroutine to read thesaurus from txt file
sub read_thesaurus {
    my %thesaurus;
    my %thesaurus_count;
    my $type = $_[0];
    open(FH, "<", "./Dictionary/thesaurus-$type.txt") or die $!;
    while(my $line = <FH>){
        my ($count, $grams, $normalized) = split("\t", $line);
        $thesaurus{$grams} = $normalized;
        $thesaurus_count{$grams} = $count;
    }
    close FH;

    # returning multiple values using array
    return (\%thesaurus, \%thesaurus_count);
}

my ($t_tekno, $t_tekno_count) = read_thesaurus("tekno");
my %thesaurus_tekno = %$t_tekno;
my %thesaurus_tekno_count = %$t_tekno_count;

my ($t_finance, $t_finance_count) = read_thesaurus("finance");
my %thesaurus_finance = %$t_finance;
my %thesaurus_finance_count = %$t_finance_count;

# Uncomment line below to run the debugger
# if( exists $thesaurus_finance{ $string_debugger } ) {
#     print "found in finance!\n";
# }
# if( exists $thesaurus_tekno{ $string_debugger } ) {
#     print "found in tekno!\n";
# }
my $size = keys %thesaurus_tekno;
my $counter = 1;

foreach my $grams(keys %thesaurus_tekno){
    
    # Uncomment line below to run the debugger
    # $grams = $string_debugger; 
    
    # Check if the corresponding grams appear on the other thesaurus
    if ( exists $thesaurus_finance{ $grams } ){
        my $threshold_count;
        my $bigger_normalized_value; # 1 for tekno, 2 for finance

        # Make sure the bigger value treated as the divisor
        if( $thesaurus_finance{ $grams } > $thesaurus_tekno{ $grams } ){
            $threshold_count = $thesaurus_tekno{ $grams } / $thesaurus_finance{ $grams };

            # To make sure we delete the element of the relevant hash
            $bigger_normalized_value = 2;
        }
        elsif( $thesaurus_finance{ $grams } < $thesaurus_tekno{ $grams } ){
            $threshold_count = $thesaurus_finance{ $grams } / $thesaurus_tekno{ $grams };

            # To make sure we delete the element of the relevant hash
            $bigger_normalized_value = 1;
        }
        else{
            # If the values are equal, the threshold_count must be 1
            $threshold_count = 1;
        }

        # Delete keys if the calculate threshold > maximum threshold
        if( $threshold_count > $threshold ){
            delete( $thesaurus_tekno{ $grams } );
            delete( $thesaurus_finance{ $grams } );
            print "$counter/$size $grams - deleted\n";
        }
        else{
            if( $bigger_normalized_value == 1 ) { 
                delete( $thesaurus_finance{ $grams } ); 

                print "$counter/$size $grams - tekno\n";
            }
            elsif( $bigger_normalized_value == 2 ) {
                delete( $thesaurus_tekno{ $grams } );
                print "$counter/$size $grams - tekno\n"; 
            }
        }
    }
    $counter++;
}

# Uncomment line below to run the debugger
# if( exists $thesaurus_finance{ $string_debugger } ) {
#     print "found in finance!\n";
# }
# if( exists $thesaurus_tekno{ $string_debugger } ) {
#     print "found in tekno!\n";
# }

open(FOTEKNO, ">", "./Dictionary/thesaurus-tekno-$threshold.txt") or die $!;
foreach my $grams( sort { $thesaurus_tekno{$b} <=> $thesaurus_tekno{$a} } keys %thesaurus_tekno ){
    print FOTEKNO "$thesaurus_tekno_count{ $grams }\t$grams\t$thesaurus_tekno{ $grams }";
}
close FOTEKNO;

open(FOFINANCE, ">", "./Dictionary/thesaurus-finance-$threshold.txt") or die $!;
foreach my $grams( sort { $thesaurus_finance{$b} <=> $thesaurus_finance{$a} } keys %thesaurus_finance ){
    print FOFINANCE "$thesaurus_finance_count{ $grams }\t$grams\t$thesaurus_finance{ $grams }";
}
close FOFINANCE;