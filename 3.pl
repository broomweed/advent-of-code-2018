#!/usr/bin/perl

use v5.12;

my %fabric = ();

for my $x (0..1000) {
    for my $y (0..1000) {
        $fabric{"$x,$y"} = 0;
    }
}

my @claims = <>;

for my $claim (@claims) {
    $claim =~ /@ (\d+),(\d+): (\d+)x(\d+)/;
    for my $x ($1..$1+$3-1) {
        for my $y ($2..$2+$4-1) {
            $fabric{"$x,$y"} ++;
        }
    }
}

say scalar grep { $_ >= 2 } values %fabric;


claim: for my $claim (@claims) {
    $claim =~ /@ (\d+),(\d+): (\d+)x(\d+)/;
    for my $x ($1..$1+$3-1) {
        for my $y ($2..$2+$4-1) {
            next claim if $fabric{"$x,$y"} > 1;
        }
    }
    die $claim;
}
