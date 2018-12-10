#!/usr/bin/perl

use v5.12;
use List::AllUtils qw( minmax );

# Just sort of tweaked these and binary-searched to find the message?
# That's probably not the best way to do it. :(
my $start = shift @ARGV;
my $timestep = shift @ARGV;

my @input = <>;
chomp @input;

my @points;
my @velocity;

for (@input) {
    /< *(-?[0-9]+), *(-?[0-9]+)>.*< *(-?[0-9]+), *(-?[0-9]+)>/;
    push @points, [ $1, $2 ];
    push @velocity, [ $3, $4 ];
}

my ($minx, $maxx) = minmax map { $_->[0] } @points;
my ($miny, $maxy) = minmax map { $_->[1] } @points;

for my $i (0..$#points) {
    $points[$i][0] += $velocity[$i][0] * $start;
    $points[$i][1] += $velocity[$i][1] * $start;
}

my $str = "";
my $oldstr = show_points();
my $count = $start;

while () {
    for my $i (0..$#points) {
        $points[$i][0] += $velocity[$i][0] * $timestep;
        $points[$i][1] += $velocity[$i][1] * $timestep;
    }

    $count += $timestep;

    $oldstr = $str;
    $str = show_points();

    if ($oldstr ne $str) {
        # if they've started moving apart again, last one might be the right answer
        say $oldstr;
        say "**************";
        say $count;
    }
}

sub show_points {
    # Hide empty lines
    my %yvals;
    my %xvals;
    @yvals{map { $_->[1], $_->[1] - 1 } @points} = (1) x @points;
    @xvals{map { $_->[0], $_->[0] - 1 } @points} = (1) x @points;
    my @okayx = sort { $a <=> $b } keys %xvals;
    my @okayy = sort { $a <=> $b } keys %yvals;

    my $str = "";

    for my $y (@okayy) {
        for my $x (@okayx) {
            if (grep { $_->[0] == $x and $_->[1] == $y } @points) {
                $str .= "#";
            } else {
                $str .= ".";
            }
        }
        $str .= "\n";
    }

    return $str;
}
