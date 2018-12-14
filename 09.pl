#!/usr/bin/perl

use v5.12;
use List::AllUtils qw( max );

my ($players, $marbles) = @ARGV;

my @marb = (0);

sub cw { push @marb, shift @marb; }

sub ccw { unshift @marb, pop @marb; }

my @players = (0) x $players;
my $pindex = 1;

for my $i (1..$marbles) {
    unless ($i % 23 == 0) {
        cw for (1..2);
        unshift @marb, $i;
    } else {
        ccw for (1..7);
        $players[$pindex] += $i + shift @marb;
    }
    $pindex ++;
    $pindex %= $players;
}

say max @players;
