#!/usr/bin/perl

use v5.12;
use List::AllUtils qw( max );

# note: this works for part 1, but is way too slow
# to use for part 2. see 9.py for a linked-list
# implementation that works better

my ($players, $marbles) = @ARGV;

{
    my @marb = (0);
    my $mindex = 0;

    my @players = (0) x $players;
    my $pindex = 1;

    for my $i (1..$marbles) {
        unless ($i % 23 == 0) {
            $mindex = ($mindex + 2) % @marb;
            $mindex = @marb if $mindex == 0;
            splice @marb, $mindex, 0, $i;
        } else {
            $players[$pindex-1] += $i;
            $mindex = ($mindex - 7) % @marb;
            $players[$pindex-1] += splice @marb, $mindex, 1;
        }
        $pindex %= $players;
        $pindex ++;
    }

    say max @players;
}
