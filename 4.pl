#!/usr/bin/perl

use v5.12;
use warnings;
use List::Util qw( sum reduce max );

my @lines = <>;

chomp @lines;
@lines = grep {$_} @lines;

@lines = sort { $a cmp $b } @lines;

my $guard;
my $asleep_time;

my %guards;

for my $line (@lines) {
    $line =~ /\[.+ ..:(\d\d)]/;
    my $minute = $1;
    if ($line =~ /Guard #(\d+) begins/) {
        $guard = $1;
        $guards{$guard} = [(0) x 60] unless defined $guards{$guard};
    } elsif ($line =~ /falls asleep/) {
        $asleep_time = $minute;
    } elsif ($line =~ /wakes up/) {
        @{ $guards{$guard} }[$asleep_time..$minute-1] = map { $_ + 1 } @{ $guards{$guard} }[$asleep_time..$minute-1];
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
