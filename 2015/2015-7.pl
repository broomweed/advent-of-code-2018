#!/usr/bin/perl

use v5.010;
use strict;
use warnings;

my @instrs = grep {$_ ne "\n"} <>;
my %wires;

for (@instrs) {
    if (/NOT (\w+) -> (\w+)/) {
        $wires{$2} = "not $1";
    } elsif (/(\w+) (\w+) (\w+) -> (\w+)/) {
        $wires{$4} = "@{[ lc $2 ]} $1 $3";
    } elsif (/(\w+) -> (\w+)/) {
        $wires{$2} = $1;
    } elsif (/(\d+) -> (\w+)/) {
        $wires{$2} = $1;
    } else {
        die "Syntax error: $_\n";
    }
}

#our $prefix = "";

my %wirevals;

sub val {
    my $wire = shift;

    if (exists $wirevals{$wire}) {
        #say $prefix, "$wire = $wirevals{$wire} (cached)";
        return $wirevals{$wire};
    }

    return $wire if $wire =~ /^\d+$/;

    if ($wires{$wire} =~ /^\d+$/) {
        #say $prefix, "$wire = $wires{$wire}";
        return $wires{$wire};
    }

    #say $prefix, "$wire = $wires{$wire} {";

    my $val;

    {
        #local $prefix = " `" . $prefix;

        if ($wires{$wire} =~ /^([^ ]+)$/) {
            my $a = $1;
            $val = val($a);
        } elsif ($wires{$wire} =~ /^not (.+)/) {
            my $a = $1;
            $val = ~val($a);
        } elsif ($wires{$wire} =~ /^lshift (\w+) (\w+)/) {
            my ($a, $b) = ($1, $2);
            $val = val($a) << val($b);
        } elsif ($wires{$wire} =~ /^rshift (\w+) (\w+)/) {
            my ($a, $b) = ($1, $2);
            $val = val($a) >> val($b);
        } elsif ($wires{$wire} =~ /^or (\w+) (\w+)/) {
            my ($a, $b) = ($1, $2);
            $val = val($a) | val($b);
        } elsif ($wires{$wire} =~ /^and (\w+) (\w+)/) {
            my ($a, $b) = ($1, $2);
            $val = val($a) & val($b);
        } else {
            die "Syntax error: $wires{$wire}";
        }
    }

    $val &= 0xffff;

    #say $prefix, "} $wire = $wires{$wire} = $val";

    $wirevals{$wire} = $val;

    return $val;
}

say val('a');
