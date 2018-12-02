#!/usr/bin/perl

use strict;
use warnings;
use v5.010;

my @input = <>;
chomp @input;

# Part 1

my $twos = grep{ contains($_, 2) } @input;
my $threes = grep { contains($_, 3) } @input;

say $twos * $threes;

sub contains {
    my ($str, $num) = @_;
    my @sames = map { my @match = ($str =~ /($_)/g); scalar @match } split //, $str;
    return grep { $_ == $num } @sames;
}

# Part 2

for my $one (@input) {
    for my $two (@input) {
        die difference($one, $two) . "\n" if differing($one, $two) == 1;
    }
}

sub zip {
    my ($a, $b) = @_;
    return map { [$a->[$_], $b->[$_]] } 0..$#$a;
}

sub differing {
    my @pairs = zip([split //, $_[0]], [split //, $_[1]]);
    return grep { $_->[0] ne $_->[1] } @pairs;
}

sub difference {
    my @pairs = zip([split //, $_[0]], [split //, $_[1]]);
    return join '', map { $_->[0] } grep { $_->[0] eq $_->[1] } @pairs;
}
