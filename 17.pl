#!/usr/bin/perl

use v5.12;
use warnings;
use List::AllUtils qw/ minmax uniq /;

my @input = <>;

my %clay;

for (@input) {
    /([xy])=(\d+), .=(\d+)..(\d+)/;
    for ($3..$4) {
        $clay{$_,$2} = '#' if $1 eq 'y';
        $clay{$2,$_} = '#' if $1 eq 'x';
    }
}

my ($top, $bottom) = minmax map { (split $;, $_)[1] } keys %clay;
say "top: $top, bottom: $bottom";

$clay{500,0} = '+';

my %pipes;

waterfall(500,0);

say "";

for my $y (0..$bottom) {
    for my $x (425..650) {
        print $clay{$x,$y} // $pipes{$x,$y} // '.';
    }
    print "\n";
}

say "standing: ", scalar grep { (split $;, $_)[1] >= $top } uniq (grep { $clay{$_} eq '~' } keys %clay);
say "flowing: ", scalar grep { (split $;, $_)[1] >= $top } uniq (keys %pipes);

say scalar grep { (split $;, $_)[1] >= $top } uniq (keys %pipes, grep { $clay{$_} eq '~' } keys %clay);

sub waterfall {
    no warnings 'recursion';

    my ($x, $y) = @_;
    print "\r$x, $y     ";

    return if $y > $bottom;

    my $look = $x;
    my ($left, $right);
    my $felloff = 0;

    while (1) {
        unless (defined $clay{$look, $y+1}) {
            waterfall($look, $y+1);
            unless (defined $clay{$look, $y+1}) {
                $pipes{$look,$y} = '|';
                $felloff = 1;
                last;
            }
        }
        $look --;
        last if defined $clay{$look, $y};
    }
    $left = $look + 1;
    $left -- if $felloff;

    $look = $x;
    while (1) {
        unless (defined $clay{$look, $y+1}) {
            waterfall($look, $y+1) unless $look == $x;
            unless (defined $clay{$look, $y+1}) {
                $pipes{$look,$y} = '|';
                $felloff = 1;
                last;
            }
        }
        $look ++;
        last if defined $clay{$look, $y};
    }
    $right = $look - 1;
    $right ++ if $felloff;

    if (not $felloff) {
        $clay{$_,$y} = '~' for ($left..$right);
    } else {
        $pipes{$_,$y} = '|' for ($left..$right);
    }
}
