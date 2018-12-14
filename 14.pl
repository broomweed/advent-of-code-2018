#!/usr/bin/perl

use v5.12;
use warnings;
use List::AllUtils qw/ sum /;

my $verbose = grep { /^-v$/ } @ARGV;
@ARGV = grep { $_ ne '-v' } @ARGV;

my $num = shift;

my @recipes = (3, 7);
my @elves = (0, 1);

while (@recipes <= $num + 10) {
    push @recipes, split //, sum map { $recipes[$_] } @elves;
    #say "@recipes";
    for my $i (0..$#elves) {
        $elves[$i] += 1 + $recipes[$elves[$i]];
        $elves[$i] %= @recipes;
    }
}

say join '', @recipes[$num..$num+9];

say "Part 2 - hold on, this'll take a while." if $verbose;

@recipes = (3, 7);
@elves = (0, 1);

my $iters = 0;

while (1) {
    push @recipes, split //, sum map { $recipes[$_] } @elves;

    last if @recipes >= (length $num) + 2 and (join '', @recipes[-(length $num)-2..-1]) =~ /$num/;

    for my $i (0..$#elves) {
        $elves[$i] += 1 + $recipes[$elves[$i]];
        $elves[$i] %= @recipes;
    }

    if ($verbose and ++$iters % 10 == 0) {
        print ("\r", scalar @recipes);
    }
}

say "\r", index ((join '', @recipes), $num), " ";
