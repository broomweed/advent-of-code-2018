#!/usr/bin/perl

use v5.010;

{ local $/ = undef; $text = <> }

$e = $text;
$e =~ s/\(/+1/g;
$e =~ s/\)/-1/g;
say eval $e;

my @arr = split //, $text;
for (@arr) {
    $i++;
    if ($_ eq '(') {
        $floor ++;
    } else {
        $floor --;
    }
    die "$i\n" if $floor < 0;
}
