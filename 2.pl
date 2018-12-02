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

sub differing {
    return grep { $_->[0] ne $_->[1] } zip_strs($_[0], $_[1]);
}

sub difference {
    return join '', map { $_->[0] } grep { $_->[0] eq $_->[1] } zip_strs($_[0], $_[1]);
}

sub zip_strs {
    my @a = split //, $_[0];
    my @b = split //, $_[1];
    return map { [$a[$_], $b[$_]] } 0..$#a;
}
