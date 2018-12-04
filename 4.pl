#!/usr/bin/perl

use v5.12;
use warnings;
use List::Util qw( sum reduce max );

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
    my $maxguard = reduce { (sum @{$guards{$a}}) > (sum @{$guards{$b}}) ? $a : $b } keys %guards;
    my @maxguardmins = @{$guards{$maxguard}};
    my $maxmin = reduce { $maxguardmins[$a] > $maxguardmins[$b] ? $a : $b } 0..$#maxguardmins;
    say $maxguard * $maxmin;
}

# Part 2

{
    my $maxguard = reduce { (max @{$guards{$a}}) > (max @{$guards{$b}}) ? $a : $b } keys %guards;
    my @maxguardmins = @{$guards{$maxguard}};
    my $maxmin = reduce { $maxguardmins[$a] > $maxguardmins[$b] ? $a : $b } 0..$#maxguardmins;
    say $maxguard * $maxmin;
}
