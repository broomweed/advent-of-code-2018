#!/usr/bin/perl

use v5.12;
use List::AllUtils qw( minmax min max_by sum );

my @coords = <>;

@coords = map { /(\d+), (\d+)/; [$1, $2] } @coords;

my ($minx, $maxx) = minmax map { $_->[0] } @coords;
my ($miny, $maxy) = minmax map { $_->[1] } @coords;

my %closest;
my %infinite;

sub manhattan {
    my ($x1, $y1, $x2, $y2) = @_;
    return abs($x1 - $x2) + abs($y1 - $y2);
}

my $part2count = 0;

for my $x ($minx..$maxx) {
    for my $y ($miny..$maxy) {

        # Part 1
        my $closestdist = 10000000;
        my @closestpts;

        for my $i (0..$#coords) {
            my $dist = manhattan($x, $y, $coords[$i][0], $coords[$i][1]);
            #print "\nDist to $i ($coords[$i][0], $coords[$i][1]): $dist";
            if ($dist <= $closestdist) {
                @closestpts = () if $dist < $closestdist;
                push @closestpts, $i;
                $closestdist = $dist;
            }
        }

        if (@closestpts == 1) {
            $closest{$x,$y} = $closestpts[0];
            if ($x == $minx or $y == $miny or $x == $maxx or $y == $maxy) {
                $infinite{$closestpts[0]} = 1;
            }
        } else {
            $closest{$x,$y} = 'TIE';
        }

        # Part 2
        my $dist = sum map { manhattan($x, $y, $coords[$_][0], $coords[$_][1]) } 0..$#coords;
        $part2count++ if $dist < 10000;

        my $percent = ($x-$minx)/($maxx-$minx);
        my $progbarlength = sprintf "%.0f", $percent * 20;
        printf "\rScanning all points: [%s%s] | Closest:%5s | Part2-Points:%6s", "#" x $progbarlength, " " x (20-$progbarlength), $closest{$x,$y}, $part2count;
    }
}

print "\nFinding biggest non-infinite area...";

my $maxpt = max_by {
    my $pt = $_;
    print "\n" if $pt % 5 == 0;
    printf "%3d%-16s", $pt, " is infinite" and return 0 if defined $infinite{$pt};
    my $size = scalar grep { $_ eq $pt } values %closest;
    printf "%3d%-16s", $pt, " has size $size";
    return $size;
} 0..$#coords;

say "\n", scalar grep { $_ eq $maxpt } values %closest, " " x 70;

say $part2count;
