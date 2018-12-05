#!/usr/bin/perl

use v5.12;
use warnings;
use List::Util qw( min );

my $input;
{   local $/ = undef;
    $input = <>;
}
chomp $input;

my @polymer = split //, $input;

sub revcase {
    my $x = shift;
    $x =~ tr/a-zA-Z/A-Za-z/;
    return $x;
}

# Part 1

sub react {
    my @polymer = @_;
    loop: while () {
        my $changed = 0;
        my $i = 1;
        while ($i <= $#polymer) {
            while ($i < @polymer and $polymer[$i] eq revcase($polymer[$i-1])) {
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

my %removes;

for my $remove ('a'..'z') {
    my @altered = grep { $_ ne $remove and $_ ne uc $remove } @polymer;
    $removes{$remove} = scalar react(@altered);
    say "$remove: $removes{$remove}";
}

say min values %removes;
