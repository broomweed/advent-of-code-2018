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
my ($left, $right) = minmax map { (split $;, $_)[0] } keys %clay;

my %pipes;

waterfall(500,0);

say "";

my $txt;

for my $y ($top..$bottom) {
    for my $x ($left-1..$right+1) {
        $txt .= $clay{$x,$y} // $pipes{$x,$y} // '.';
    }
    $txt .= "\n";
}

say $txt;
say scalar grep { $_ eq '|' or $_ eq '~' } split //, $txt;

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
