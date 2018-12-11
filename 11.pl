#!/usr/bin/perl

use v5.12;
use List::AllUtils qw/ max_by /;
use integer;

my $serial = shift;
my $maxsize = shift // 40;

sub powerlevel {
    my ($x, $y) = @_;
    my $pl = (($x + 10) * $y + $serial) * ($x + 10);
    $pl = (split //, $pl)[-3];
    $pl -= 5;
    return $pl;
}

my %pls;

for my $size (1..$maxsize) {
    say "considering $size";

    for my $x (1..301-$size) {
        for my $y (1..301-$size) {
            my $total;

            if ($size == 1) {
                $total = powerlevel($x, $y);
            } elsif ($size % 2 == 0) {
                $total = $pls{$x, $y, $size/2}
                       + $pls{$x+$size/2, $y, $size/2}
                       + $pls{$x, $y+$size/2, $size/2}
                       + $pls{$x+$size/2, $y+$size/2, $size/2};
            } else {
                $total = $pls{$x, $y, $size/2}
                       + $pls{$x+$size/2, $y, $size/2+1}
                       + $pls{$x, $y+$size/2, $size/2+1}
                       + $pls{$x+$size/2+1, $y+$size/2+1, $size/2};
                $total -= powerlevel($x+$size/2, $y+$size/2);
            }

            $pls{$x,$y,$size} = $total;
        }
    }

    if ($size % 50 == 0) {
        my $bestkey = max_by { $pls{$_} } keys %pls;
        say "Best so far: ", (join ', ', split $;, $bestkey), " => ", $pls{$bestkey};
    }
}

my $bestkey = max_by { $pls{$_} } keys %pls;
say "Best found: ", (join ', ', split $;, $bestkey), " => ", $pls{$bestkey};
