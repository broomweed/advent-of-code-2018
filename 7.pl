#!/usr/bin/perl

use v5.12;
use List::AllUtils qw( all none );

my @input = <>;

my %prereqs;

for my $req (@input) {
    $req =~ /([A-Z]) must be .+ step ([A-Z]) can/;
    $prereqs{$1} = [] if not exists $prereqs{$1};
    $prereqs{$2} = [] if not exists $prereqs{$2};
    push @{$prereqs{$2}}, $1;
}

my @steps = keys %prereqs;

# Part 1

{
    my %completed;

    while (keys %completed < keys %prereqs) {
        my @candonext = sort { $a cmp $b } grep { not exists $completed{$_} and all { exists $completed{$_} } @{$prereqs{$_}} } @steps;
        print $candonext[0];
        $completed{$candonext[0]} = 1;
    }

    say "";
}

# Part 2

sub tasktime {
    return (ord $_[0]) - (ord 'A') + 1 + 60;
}

{
    my %completed;
    my @completed;
    my $time = 0;
    my $nworkers = 5;

    my @workers = ('.') x $nworkers;
    my @tasktimes = (0) x $nworkers;

    my $cols_width = @workers * 2 - 1;
    printf "%5s %-${cols_width}s %s\n", "TIME", "WORKERS", "COMPLETED";

    do {
        for my $worker (0..$#workers) {
            $tasktimes[$worker] --;
            if ($tasktimes[$worker] <= 0) {
                $completed{$workers[$worker]} = 1 if $workers[$worker] ne '.';
                $workers[$worker] = '.';
                my @candonext = sort { $a cmp $b } grep { not exists $completed{$_} and all { exists $completed{$_} } @{$prereqs{$_}} } @steps;
                @candonext = grep { my $task = $_; none { $_ eq $task } @workers } @candonext;
                if (@candonext) {
                    $workers[$worker] = $candonext[0];
                    $tasktimes[$worker] = tasktime $candonext[0];
                }
            }
        }
        printf "%5d %${cols_width}s %s\n", $time, (join ' ', @workers), (join '', map {lc} sort keys %completed);
        $time++;
    } until (all { $_ eq '.' } @workers);

    say $time - 1;
}
