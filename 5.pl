#!/usr/bin/perl

use v5.12;
use warnings;
use List::Util qw( min );

my $input;
{
    local $/ = undef;
    $input = <>;
}
chomp $input;

my @polymer = split //, $input;

sub oppositecase {
    return lc $_[0] eq lc $_[1] && $_[0] ne $_[1];
}

# Part 1

sub react {
    my @polymer = @_;
    loop: while () {
        my $changed = 0;
        my $i = 1;
        while ($i < @polymer) {
            while ($i < @polymer and oppositecase $polymer[$i], $polymer[$i-1]) {
                $changed ++;
                splice @polymer, $i-1, 2;
            }
            $i++;
        }
        last if not $changed;
    }
    return @polymer;
}

@polymer = react(@polymer);
say scalar @polymer;

# Part 2

say min map { my $remove = $_; scalar react(grep { $_ ne $remove and $_ ne uc $remove } @polymer) } 'a'..'z';
