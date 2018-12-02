#!/usr/bin/perl

use v5.010;

$tx = <>;
@a = split //,$tx;

$x = 0;
$y = 0;
for (@a) {
    $houses{"$x,$y"} ++;
    $x ++ if $_ eq ">";
    $x -- if $_ eq "<";
    $y ++ if $_ eq "v";
    $y -- if $_ eq "^";
}
$houses{"$x,$y"} ++;

say scalar keys %houses;

@a2 = split /(..)/,$tx;

$x1 = 0;
$y1 = 0;
$x2 = 0;
$y2 = 0;
for (@a2) {
    my ($a, $b) = split //, $_;

    $houses2{"$x1,$y1"} ++;
    $x1 ++ if $a eq ">";
    $x1 -- if $a eq "<";
    $y1 ++ if $a eq "v";
    $y1 -- if $a eq "^";

    $houses2{"$x2,$y2"} ++;
    $x2 ++ if $b eq ">";
    $x2 -- if $b eq "<";
    $y2 ++ if $b eq "v";
    $y2 -- if $b eq "^";
}
$houses2{"$x1,$y1"} ++;
$houses2{"$x2,$y2"} ++;

say scalar keys %houses2;
