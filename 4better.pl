#!/usr/bin/perl

use v5.12;
use warnings;
use List::Util qw( sum reduce max );
use List::UtilsBy qw( max_by );

my @lines = sort { $a cmp $b } <>;

my %guards;

my $guard;
my $asleep_time;

sub incr {
    for my $idx (0..$#_) {
        $_[$idx]++;
    }
}

for my $line (@lines) {
    $line =~ /\[.+ ..:(\d\d)]/;
    my $minute = $1;
    if ($line =~ /Guard #(\d+) begins/) {
        $guard = $1;
        $guards{$guard} = [(0) x 60] unless defined $guards{$guard};
    } elsif ($line =~ /falls asleep/) {
        $asleep_time = $minute;
    } elsif ($line =~ /wakes up/) {
        incr @{ $guards{$guard} }[$asleep_time..$minute-1];
    }
}

# Part 1

{
    my $maxguard = max_by { sum @{$guards{$_}} } keys %guards;
    my $maxminute = max_by { $guards{$maxguard}[$_] } 0..59;
    say $maxguard * $maxminute;
}

# Part 2

{
    my $maxguard = max_by { max @{$guards{$_}} } keys %guards;
    my $maxminute = max_by { $guards{$maxguard}[$_] } 0..59;
    say $maxguard * $maxminute;
}
