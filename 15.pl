#!/usr/bin/perl

use strict;
use warnings;
use v5.012;

use List::AllUtils qw/max any none min sum uniq_by/;

my %input = ();
my $height;
my $width = 0;

my $verbose = grep { $_ eq '-v' } @ARGV;
@ARGV = grep { $_ ne '-v' } @ARGV;

my $y = 0;
for my $line (<>) {
    chomp $line;
    my @chars = split //, $line;
    $width = max $width, @chars - 1;
    for my $x (0..$width) {
        $input{$x,$y} = $chars[$x];
    }
    $y ++;
}
$height = $y - 1;

my @units;
my %map;

sub do_combat {
    # parameters: elf attack power, and whether we should cut it short if an elf dies
    my ($elfpower, $part2) = @_;

    my $elfdeaths = 0;

    @units = ();
    %map = ();

    for my $y (0..$height) {
        for my $x (0..$width) {
            if (defined $input{$x,$y}) {
                $map{$x,$y} = $input{$x,$y};
            } else {
                $map{$x,$y} = '#';
            }
            if ($map{$x,$y} eq 'G') {
                push @units, { sym => 'G', x => $x, y => $y, attack => 3, hp => 200 };
                $map{$x,$y} = '.';
            }
            if ($map{$x,$y} eq 'E') {
                push @units, { sym => 'E', x => $x, y => $y, attack => $elfpower, hp => 200 };
                $map{$x,$y} = '.';
            }
        }
    }

    print_board() if $verbose;

    my $round = 0;

    round: while (1) {
        @units = sort { reading_order_sort([$a->{x}, $a->{y}], [$b->{x}, $b->{y}]) } @units;

        my @remaining_units = @units;
        unit: while (@remaining_units) {
            # Have to do this weird thing so we can remove dead units after each unit's turn.
            @remaining_units = grep { not exists $_->{dead} } @remaining_units;
            my $unit = shift @remaining_units;

            my @enemies = grep { not exists $_->{dead} and $_->{sym} ne $unit->{sym} } @units;

            # Combat ends if there are no more enemies
            say "\nCombat finished." and last round if not @enemies;

            # Construct list of valid adjacent squares to enemies
            my @all_adjacent = map { adjacent_squares($_->{x}, $_->{y}) } @enemies;
            my @open_adjacent = grep { open_square(@$_) } @all_adjacent;

            # are we in range? (i.e. is our current position one of these adjacent squares)
            my @in_attack_range = grep { $_->[0] == $unit->{x} && $_->[1] == $unit->{y} } @all_adjacent;

            if (not @in_attack_range) {
                # We're making a move

                # Move on if no target squares available
                next unit if not @open_adjacent;

                # Find the closest target squares
                my %distances = ();
                my @outer_ring = ( [$unit->{x}, $unit->{y}] );
                my $current_distance = 0;
                my @reachable_targets = ();
                # we go until we find an enemy, or until we run out of squares to check
                # breadth-first search from our unit's position, by finding all adjacent squares
                # to the last set we checked (which is @outer_ring); we then remove already-checked
                # squares so we get all adjacent squares we haven't looked at yet.
                # We stop when we run out of squares (i.e. no possible path to enemy) or when we
                # find at least one enemy-adjacent square to move to (since it'll be guaranteed to
                # be the closest one.... if it weren't, we'd have found a different one first)
                while (@outer_ring && !@reachable_targets) {
                    # Fill in the current outer ring with the current distance away from the target
                    @distances{map { join $;, @$_ } @outer_ring} = ($current_distance) x @outer_ring;
                    # find all squares adjacent to our currently-looking-at squares that we haven't looked
                    # at yet (and uniq-ify them by their coordinates so we don't have a crazy explosion
                    # on bigger maps)
                    @outer_ring = uniq_by { join $;, @$_ }
                                     grep { open_square(@$_) }
                                     grep { not exists $distances{join $;, @$_} }
                                      map { adjacent_squares(@$_) } @outer_ring;

                    push @reachable_targets, grep {
                        # Check if any open adjacent-to-enemy squares are in our outer ring.
                        my ($x, $y) = @$_;
                        grep { $_->[0] == $x and $_->[1] == $y } @open_adjacent
                    } @outer_ring;

                    # Increase the distance counter from the center
                    $current_distance ++;
                }

                # If we didn't find any reachable targets, stop and move on
                next unit unless @reachable_targets;

                # Find reachable target first in reading order
                @reachable_targets = sort { reading_order_sort($a, $b) } @reachable_targets;
                my $target_square = $reachable_targets[0];

                # Now we do a similar process as above to find the best way to move
                %distances = ();
                @outer_ring = ( $target_square );
                $current_distance = 0;
                while (@outer_ring) {
                    @distances{map { join $;, @$_ } @outer_ring} = ($current_distance) x @outer_ring;
                    # find all squares adjacent to us that we haven't looked at yet
                    @outer_ring = grep { open_square(@$_) }
                                  grep { not exists $distances{join $;, @$_} }
                               uniq_by { join $;, @$_ }
                                   map { adjacent_squares(@$_) } @outer_ring;
                    $current_distance ++;
                }

                # Find shortest distance, then find which squares have shortest distance
                my @neighbors = grep { open_square(@$_) } adjacent_squares($unit->{x}, $unit->{y});
                # Eliminate neighbor squares that don't pathfind to the enemy unit
                @neighbors = grep { defined $distances{join $;, @$_} } @neighbors;
                # If we can move anywhere...
                if (@neighbors) {
                    # Find which squares have the shortest distance (so we can pick the reading-order-first one)
                    my $short_dist = min map { $distances{join $;, @$_} } @neighbors;
                    my @short_squares = grep { $distances{join $;, @$_} == $short_dist } @neighbors;
                    @short_squares = sort { reading_order_sort($a, $b) } @short_squares;
                    #say "Unit $unit->{x}, $unit->{y} moved to $short_squares[0][0], $short_squares[0][1]";
                    $unit->{x} = $short_squares[0][0];
                    $unit->{y} = $short_squares[0][1];
                }
            }

            # Now that we moved (or maybe not), we attack if we're in range.
            # So check if we're next to an enemy.
            my @adjacent_enemies = grep {
                my $dx = abs ($_->{x} - $unit->{x});
                my $dy = abs ($_->{y} - $unit->{y});
                ($dx == 1 && $dy == 0) || ($dx == 0 && $dy == 1);
            } @enemies;

            if (@adjacent_enemies) {
                # Do an attack
                my $min_hp = min map { $_->{hp} } @adjacent_enemies;
                my @targets = sort { reading_order_sort([$a->{x}, $a->{y}], [$b->{x}, $b->{y}]) }
                              grep { $_->{hp} == $min_hp } @adjacent_enemies;
                my $target = $targets[0];

                $target->{hp} -= $unit->{attack};
                $target->{dead} = 1 if $target->{hp} <= 0;
            }
        }

        my @dead = grep { exists $_->{dead} } @units;
        $elfdeaths += grep { $_->{sym} eq 'E' } @dead;
        # if we're short circuiting bc part 2, stop when an elf dies
        last round if $elfdeaths and $part2;

        @units = grep { not exists $_->{dead} } @units;

        $round ++;

        say "\nAfter $round rounds with $elfpower elfpower:" if $verbose;
        print_board() if $verbose;
    }

    @units = grep { not exists $_->{dead} } @units;
    print_board() if $verbose;

    my $winner = $units[0]{sym} eq 'E' ? 'elves' : 'goblins';
    my $totalhp = sum map { $_->{hp} } @units;

    return ($winner, $totalhp, $round, $elfdeaths);
}

# Part 1
say "-- Running part 1 --";

my ($winner, $totalhp, $round) = do_combat(3);

my $part1result = <<END

==== PART 1 RESULTS ====

Combat ends after $round full rounds.
@{[ucfirst $winner]} win with $totalhp total hit points left.
Outcome: $round * $totalhp = @{[$round * $totalhp]}
END
;

# Part 2
say "\n-- Running part 2 --\n";

my $elfpower = 3;

my $elfdeaths = 1;
while ($elfdeaths) {
    $elfpower++;
    say "Trying with $elfpower elfpower.";
    ($winner, $totalhp, $round, $elfdeaths) = do_combat($elfpower, 1);
}

my $part2result = <<END

==== PART 2 RESULTS ====

Elves need $elfpower power to win.
Combat ends after $round full rounds.
@{[ucfirst $winner]} win with $totalhp total hit points left.
Outcome: $round * $totalhp = @{[$round * $totalhp]}
END
;

say $part1result;
say $part2result;

sub adjacent_squares {
    # Return the four coordinates of adjacent squares to a coordinate
    my ($x, $y) = @_;
    return ([$x, $y - 1], [$x - 1, $y], [$x + 1, $y], [$x, $y + 1]);
}

sub open_square {
    # Check that it's empty ground and that there's no one standing there
    my ($x, $y) = @_;
    return $map{$x,$y} eq '.' && none { $_->{x} == $x and $_->{y} == $y } grep { not exists $_->{dead} } @units;
}

sub reading_order_sort {
    # reading order sort: sort first by y-coordinate, then x-coordinate
    return $_[0][1] <=> $_[1][1] || $_[0][0] <=> $_[1][0];
}

sub print_board {
    for my $y (0..$height) {
        my @line_units = ();
        for my $x (0..$width) {
            my @on_square = grep { $_->{x} == $x && $_->{y} == $y } @units;
            if (@on_square) {
                push @line_units, @on_square;
                print $on_square[0]{sym};
            } else {
                print $map{$x,$y};
            }
        }
        print "  ", join ', ', map { "$_->{sym}($_->{hp})" } @line_units;
        print "\n";
    }
}
