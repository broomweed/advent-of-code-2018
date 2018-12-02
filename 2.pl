#!/usr/bin/perl

use v5.010;
my @input = <>;
chomp @input;

# Part 1

for (@input) {
    $twos ++ if contains($_, 2);
    $threes ++ if contains($_, 3);
}

say $twos * $threes;

sub contains {
    my ($str, $num) = @_;
    for my $ch (split //, $str) {
        my @matches = ($str =~ /($ch)/g);
        return 1 if (scalar @matches) == $num;
    }
    return 0;
}

# Part 2

for $one (@input) {
    for $two (@input) {
        die difference($one, $two) . "\n" if differing($one, $two) == 1;
    }
}

sub differing {
    my ($one, $two) = @_;
    my $count = 0;
    for my $idx (0..length $one) {
        $count ++ if (substr $two, $idx, 1) ne (substr $one, $idx, 1);
    }
    return $count;
}

sub difference{
    my ($one, $two) = @_;
    my $diff = "";
    for my $idx (0..length $one) {
        $diff .= (substr $two, $idx, 1) if (substr $two, $idx, 1) eq (substr $one, $idx, 1);
    }
    return $diff;
}
