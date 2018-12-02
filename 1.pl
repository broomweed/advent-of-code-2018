#!/usr/bin/perl

# Run like: ./1.pl <input>
# Can also take input from stdin thanks to ~the magic of Perl~

use strict;
use warnings;
use List::Util qw( sum );
use v5.010;

my @nums = grep {$_ ne "\n"} <>;

say "Part 1: ", sum @nums;

my %used;
my $total = 0;
rep: while (1) {
    for (@nums) {
        $total += $_;
        last rep if $used{$total};
        $used{$total} = 1;
    }
}

say "Part 2: $total";
