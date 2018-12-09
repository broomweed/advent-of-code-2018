#!/usr/bin/python3

import sys

# Sorry Perl, your arrays are too slow and you don't have
# a good way to make a linked list :(

class Marble:
    def __init__(self, val):
        self.val = val

        # At this point, while it contains only a single marble,
        # it is still a circle: the marble is both clockwise
        # from itself and counter-clockwise from itself.
        self.prev = self
        self.next = self

    def __str__(self):
        # print out the circle starting at this marble
        s = str(self.val)
        marb = self.next
        while marb is not self:
            s += " " + str(marb.val)
            marb = marb.next
        return s

players = int(sys.argv[1])
marbles = int(sys.argv[2])

curr_player = 0

player_scores = [0] * players;

# First, the marble numbered 0 is placed in the circle....
# This marble is designated the current marble.
curr_marble = Marble(0)

def add(num):
    global curr_player, curr_marble

    if num % 23 != 0:
        # Then, each Elf takes a turn placing the lowest-
        # numbered remaining marble into the circle...
        new_marble = Marble(num)

        # ...between the marbles that are 1 and 2 marbles
        # clockwise of the current marble.
        new_marble.next = curr_marble.next.next
        new_marble.prev = curr_marble.next

        curr_marble.next.next.prev = new_marble
        curr_marble.next.next = new_marble

        # The marble that was just placed then becomes the
        # current marble.
        curr_marble = new_marble

    # However, if the marble that is about to be placed has
    # a number which is a multiple of 23, something entirely
    # different happens.
    else:
        # First, the current player keeps the marble they
        # would have placed, adding it to their score.
        player_scores[curr_player] += num

        # In addition, the marble 7 marbles counter-clockwise
        # from the current marble...
        for i in range(7):
            curr_marble = curr_marble.prev

        # ...is removed from the circle...
        curr_marble.prev.next = curr_marble.next
        curr_marble.next.prev = curr_marble.prev

        # ...and also added to the current player's score.
        player_scores[curr_player] += curr_marble.val

        # The marble located immediately clockwise of the marble
        # that was removed becomes the new current marble.
        curr_marble = curr_marble.next

    curr_player += 1
    curr_player %= players

# The marbles are numbered starting with 0 and increasing by
# 1 until every marble has a number.
for i in range(marbles):
    add(i)

print(max(player_scores))
