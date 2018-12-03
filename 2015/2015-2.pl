#!/usr/bin/perl
use v5.012;
use List::Util qw( sum min product );

my (@dims, $total, $total2);

while (<>) {
    next if $_ eq "\n";
    /(.+)x(.+)x(.+)/;
    push @dims, [$1, $2, $3];
}

for (@dims) {
    my @x = @$_;
    my @sides = ( $x[0] * $x[1], $x[1] * $x[2], $x[2] * $x[0] );
    $total += 2 * (sum @sides) + (min @sides);
}

say $total;

for (@dims) {
    my @x = @$_;
    my $vol = product @x;
    my @perims = ( $x[0] + $x[1], $x[1] + $x[2], $x[2] + $x[0] );
    $total2 += 2 * (min @perims) + $vol;
}

say $total2;
