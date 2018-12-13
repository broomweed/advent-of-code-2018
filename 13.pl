#!/usr/bin/perl

use v5.12;
use warnings;
use Data::Dumper;
use List::AllUtils qw/ max /;
use Time::HiRes qw/ usleep /;

# read it in as a 2d array
my @input = <>;
chomp @input;
@input = grep { @$_ > 0 } map { [split //, $_] } @input;

# get dimensions
my ($height, $width) = (@input, max map { scalar @$_ } @input);

# put tracks into a more perl-friendly data structure
my %tracks;
for my $y (0..$#input) {
    for my $x (0..$#{$input[$y]}) {
        $tracks{$x,$y} = $input[$y][$x];
    }
}

# find all the carts, convert them to [x, y, character, state]
# where state is # of intersections crossed

# (note: @carts is 'our' so we can use 'local' to save its original
#  value to reset for part 2. this has been Stupid Perl Tricks™)
our @carts = map { [(split $;, $_), $tracks{$_}, 0] } grep { $tracks{$_} =~ /[v^<>]/ } keys %tracks;

# convert the cart positions in input into straight tracks
# as per directions
@tracks{keys %tracks} = map { my $x = $_; $x =~ s/[<>]/-/; $x =~ s/[v^]/|/; $x } values %tracks;

# print out the track (for debugging purposes)
sub show {
    for my $y (0..$height-1) {
        for my $x (0..$width-1) {
            my ($cart) = grep { $_->[0] ne 'REMOVED' }
                         grep { $_->[0] == $x and $_->[1] == $y }
                             @carts;
            if ($cart) {
                print $cart->[2];
            } else {
                print $tracks{$x,$y} // ' ';
            }
        }
        print "\n";
    }
}

# functions to turn carts left or right
sub turnright { $_[0][2] =~ tr/^<v>/>^<v/; }

sub turnleft { $_[0][2] =~ tr/^<v>/<v>^/; }

# Update function
my $collided;
my $part;
sub update {
    # carts update from top to bottom, left to right, so sort by y first then x
    for my $cart (sort { $a->[1] <=> $b->[1] or $a->[0] <=> $b->[0] } @carts) {
        my ($x, $y, $sym, $state) = @$cart;

        # skip carts removed due to collision
        next if $x eq 'REMOVED';

        # move carts
        if ($sym eq 'v') {
            $y ++;
        } elsif ($sym eq '^') {
            $y --;
        } elsif ($sym eq '<') {
            $x --;
        } elsif ($sym eq '>') {
            $x ++;
        }

        # update x/y variables
        @$cart[0..1] = ($x, $y);

        # check if we collided with anything
        my ($collision) = grep { $_ != $cart }
                          grep { $_->[0] == $x and $_->[1] == $y }
                          grep { $_->[0] ne 'REMOVED' }
                              @carts;

        # handle collision either by ending the function and printing
        # coordinates (part 1), or by removing the two colliding
        # carts (part 2)
        if ($collision) {
            if ($part == 1) {
                $collided = 1;
                say "$x,$y";
                last;
            } else {
                $collision->[0] = 'REMOVED';
                $cart->[0] = 'REMOVED';
                next;
            }
        }

        # turn the cart based on the track under it
        my $track = $tracks{$x,$y};

        if ($track eq '/') {
            turnright $cart if $sym =~ /[v^]/;
            turnleft $cart if $sym =~ /[<>]/;
        } elsif ($track eq '\\') {
            turnleft $cart if $sym =~ /[v^]/;
            turnright $cart if $sym =~ /[<>]/;
        } elsif ($track eq '+') {
            if ($state % 3 == 0) {
                turnleft $cart;
            } elsif ($state % 3 == 2) {
                turnright $cart;
            }
            $cart->[3] ++;
        }
    }

    # remove all REMOVED carts
    @carts = grep { $_->[0] ne 'REMOVED' } @carts;
}

# Part 1
{
    $part = 1;

    # make a copy of carts so we reset to initial
    # conditions upon leaving this scope
    local @carts = map { [ @$_ ] } @carts;

    do {
        update;
    } until ($collided);
}

# Part 2
{
    $part = 2;

    local @carts = map { [ @$_ ] } @carts;

    do {
        update;
    } until (@carts <= 1);

    say "$carts[0][0],$carts[0][1]";
}
