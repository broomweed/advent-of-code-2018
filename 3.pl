#!/usr/bin/perl

use v5.12;

# Part 1

my %fabric = ();

my @claims = <>;

for my $claim (@claims) {
    $claim =~ /@ (\d+),(\d+): (\d+)x(\d+)/;
    for my $x ($1..$1+$3-1) {
        for my $y ($2..$2+$4-1) {
            $fabric{$x,$y} ++;
        }
    }
}

say scalar grep { $_ >= 2 } values %fabric;

# Part 2

claim: for my $claim (@claims) {
    $claim =~ /#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/;
    for my $x ($2..$2+$4-1) {
        for my $y ($3..$3+$5-1) {
            next claim if $fabric{$x,$y} > 1;
        }
    }
    die "$1\n";
}
