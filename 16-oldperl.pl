#!/usr/bin/perl

# This version will run under versions of perl older than 5.22.
# since it doesn't use refaliasing.
# This means I had to make the syntax clunkier :(

use strict;
use warnings;

use v5.012;

use Data::Dumper;

my $verbose = grep { $_ eq '-v' } @ARGV;
@ARGV = grep { $_ ne '-v' } @ARGV;

# Parse the input.

my @input = <>;
chomp @input;

my @tests;

# Parse before/after
while ($input[0] =~ /Before: /) {
    my $before = shift @input;
    $before =~ /(\d+), (\d+), (\d+), (\d+)/;
    my @befores = ($1, $2, $3, $4);

    my $middle = shift @input;
    $middle =~ /(\d+) (\d+) (\d+) (\d+)/;
    my @middles = ($1, $2, $3, $4);

    my $after = shift @input;
    $after =~ /(\d+), (\d+), (\d+), (\d+)/;
    my @afters = ($1, $2, $3, $4);

    push @tests, [ [ @befores ], [ @middles ], [ @afters ] ];

    shift @input;
}

my @testprogram = ();
if (@input) {
    # If more input, it's the test program

    # Skip empty lines
    shift @input while length $input[0] == 0;

    # Parse test program
    @testprogram = map { $_ =~ /(\d+) (\d+) (\d+) (\d+)/; [ $1, $2, $3, $4 ] } @input;
}

# opcode stuff
# We pass them 4 inputs:
#  0 1 2 3
#  A B C [reg0, reg1, reg2, reg3]

# holy line noise, batman!
my %opcodes = (
    addr => sub {
        $_[3][$_[2]] = $_[3][$_[0]] + $_[3][$_[1]]
    },
    addi => sub {
        $_[3][$_[2]] = $_[3][$_[0]] + $_[1]
    },
    mulr => sub {
        $_[3][$_[2]] = $_[3][$_[0]] * $_[3][$_[1]]
    },
    muli => sub {
        $_[3][$_[2]] = $_[3][$_[0]] * $_[1]
    },
    banr => sub {
        $_[3][$_[2]] = $_[3][$_[0]] & $_[3][$_[1]]
    },
    bani => sub {
        $_[3][$_[2]] = $_[3][$_[0]] & $_[1]
    },
    borr => sub {
        $_[3][$_[2]] = $_[3][$_[0]] | $_[3][$_[1]]
    },
    bori => sub {
        $_[3][$_[2]] = $_[3][$_[0]] | $_[1]
    },
    setr => sub {
        $_[3][$_[2]] = $_[3][$_[0]]
    },
    seti => sub {
        $_[3][$_[2]] = $_[0]
    },
    gtir => sub {
        $_[3][$_[2]] = $_[0] > $_[3][$_[1]] ? 1 : 0
    },
    gtri => sub {
        $_[3][$_[2]] = $_[3][$_[0]] > $_[1] ? 1 : 0
    },
    gtrr => sub {
        $_[3][$_[2]] = $_[3][$_[0]] > $_[3][$_[1]] ? 1 : 0
    },
    eqir => sub {
        $_[3][$_[2]] = $_[0] == $_[3][$_[1]] ? 1 : 0
    },
    eqri => sub {
        $_[3][$_[2]] = $_[3][$_[0]] == $_[1] ? 1 : 0
    },
    eqrr => sub {
        $_[3][$_[2]] = $_[3][$_[0]] == $_[3][$_[1]] ? 1 : 0
    },
);

# PART ONE

print "Part one: " if $verbose;
say scalar grep { @$_ >= 3 } map { [ looks_like(@$_) ] } @tests;

# PART TWO

say "-----" if $verbose;

my %couldbe = ();

for my $test (@tests) {
    my @before = @{$test->[0]};
    my @middle = @{$test->[1]};
    my @after = @{$test->[2]};

    my $opnum = $middle[0];

    my @result = looks_like(@$test);

    $couldbe{$opnum} = [ keys %opcodes ] if not exists $couldbe{$opnum};

    # Filter what a given opnum could be by limiting it to stuff already in result
    # The thing inside grep is just checking if it's in @result.
    # Wish perl had a better 'is in list' operator
    @{$couldbe{$opnum}} = grep { my $c = $_; (grep { $_ eq $c } @result) > 0 } @{$couldbe{$opnum}};
}

my %instructions = ();

while (keys %couldbe) {
    # Find codes that could only correspond to a single instruction
    my @singles = grep { @{$couldbe{$_}} == 1 } keys %couldbe;

    # Just pick the first one to make it simple
    my $single_instr = $singles[0];

    # Place it into the real instruction table
    $instructions{$single_instr} = $couldbe{$single_instr}[0];

    # Remove it from the possible-instruction table
    delete $couldbe{$single_instr};

    # Now remove the instruction from the list of 'instructions each remaining code could be'
    @couldbe{keys %couldbe} = map { [ grep { $_ ne $instructions{$single_instr} } @{$couldbe{$_}} ] } keys %couldbe;
}

for my $code (sort { $a <=> $b } keys %instructions) {
    say "$code => $instructions{$code}" if $verbose;
}

# Run the test program.

my $regs = [ 0, 0, 0, 0 ];
for my $line (@testprogram) {
    my @line = @$line;
    $opcodes{$instructions{$line[0]}}->(@line[1..3], $regs);
}

print "Part two: " if $verbose;
say $regs->[0];

# returns which opcodes a given sample could be
sub looks_like {
    # PATTERN MATCHING! now we just need declared_refs too
    # (but it's not available in my version of perl (5.22))
    my @before = @{$_[0]};
    my @middle = @{$_[1]};
    my @after = @{$_[2]};

    # lookslike: number of opcodes this one looks like
    my @lookslike = ();

    opcode: for my $oc (keys %opcodes) {
        my $regs = [ @before ];

        $opcodes{$oc}(@middle[1..3], $regs);

        for my $i (0..3) {
            if ($regs->[$i] != $after[$i]) {
                # uh oh, an opcode didn't match, so skip it
                next opcode;
            }
        }

        # registers matched 'after', so it looks like this instruction
        push @lookslike, $oc;
    }

    return @lookslike;
}
