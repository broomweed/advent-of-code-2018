#!/usr/bin/perl

use v5.12;
use warnings;
use List::AllUtils qw/ sum /;

# Pass '20' as first argument for part 1,
# '50000000000' as first argument for part 2.
my $generations = shift;

my @input = <>;
chomp @input;

my $state = shift @input;
$state =~ s/^.*: //;

shift @input;

my %rules;

for my $rule (@input) {
    $rule =~ /([.#]+) => ([.#])/;
    $rules{$1} = $2;
}

my $offset = 0;
say "0: $state";

my $iters = 0;
my $oldstr = '';
my $incr;

for (1..$generations) {
    $iters = $_;

    my @arr = (('.') x 5, (split //, $state), ('.') x 5);
    $state = '';

    for my $i (2..$#arr-2) {
        $state .= $rules{join '', @arr[$i-2..$i+2]} // '.';
    }

    $state =~ /^(\.*)/;
    $incr = (length $1) - 3;
    $offset += $incr;
    $state =~ s/^\.+|\.+$//g;

    print " " x 12;
    if ($offset < 0) {
        say (" " x - $offset, "0");
    } else {
        say $offset;
    }
    printf "%10d: $state\n", $iters;

    # Find the point ($iters) where they all start sliding one way, then figure out
    # how much they're sliding by ($incr), and use that to calculate where they'll
    # be 50 billion (or 20, maybe) generations in the future.
    last if $state eq $oldstr;
    $oldstr = $state;
}

my @arr = split //, $state;

my @plant = map { $_ + $offset + $incr * ($generations - $iters) } grep { $arr[$_] eq '#' } 0..$#arr;

say sum @plant;
