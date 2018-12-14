#!/usr/bin/perl

use v5.12;
use List::AllUtils qw( sum );

my $verbose = grep { $_ eq '-v' } @ARGV;
@ARGV = grep { $_ ne '-v' } @ARGV;

my @nums;
{
    local $/ = " ";
    @nums = <>;
    chomp @nums;
}

our $prefix = "";

sub value {
    my ($children, $meta, @rest) = @_;
    my ($value, @metas);
    my $sum = 0;
    say $prefix, "$children children, $meta metas:" if $verbose;
    if ($children == 0) {
        @metas = splice @rest, 0, $meta;
        $value = sum @metas;
    } else {
        my @childnums = ();
        for (1..$children) {
            local $prefix = $prefix . "  ";
            (my $chsum, my $chval, @rest) = value(@rest);
            push @childnums, $chval;
            $sum += $chsum;
        }
        @metas = splice @rest, 0, $meta;
        my @idxmetas = map { $_ - 1 } grep { $_ != 0 } @metas;
        $value = sum @childnums[@idxmetas];
    }
    say $prefix, "Metadata: @metas" if $verbose;
    say $prefix, "Value: $value" if $verbose;
    $sum += sum @metas;
    return $sum, $value, @rest;
}

my ($part1, $part2) = value @nums;

say $part1;
say $part2;
