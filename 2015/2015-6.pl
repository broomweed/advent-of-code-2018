#!/usr/bin/perl

use v5.010;
use List::Util qw(sum);

my @instrs = <>;

# part 1
for my $x (0..999) {
    for my $y (0..999) {
        $lights{"$x,$y"} = 0;
    }
}

for (@instrs) {
    /(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)/;
    for my $x ($2..$4) {
        for my $y ($3..$5) {
            if ($1 eq 'turn on') {
                $lights{"$x,$y"} = 1;
            } elsif ($1 eq 'turn off') {
                $lights{"$x,$y"} = 0;
            } else {
                $lights{"$x,$y"} = not $lights{"$x,$y"};
            }
        }
    }
}

say scalar grep {$_} values %lights;

# part 2
for my $x (0..999) {
    for my $y (0..999) {
        $lights{"$x,$y"} = 0;
    }
}

for (@instrs) {
    /(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)/;
    for my $x ($2..$4) {
        for my $y ($3..$5) {
            if ($1 eq 'turn on') {
                $lights{"$x,$y"}++;
            } elsif ($1 eq 'turn off') {
                $lights{"$x,$y"}--;
                $lights{"$x,$y"} = 0 if $lights{"$x,$y"} < 0;
            } else {
                $lights{"$x,$y"} += 2;
            }
        }
    }
}

say sum values %lights;
