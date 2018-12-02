#!/usr/bin/perl
use v5.010;

@strings = <>;

say scalar grep { nice1($_) } @strings;
say scalar grep { nice2($_) } @strings;

# part 1
sub nice1 {
    return 0 if $_[0] !~ /(\w)\1/;
    return 0 if $_[0] =~ /ab|cd|pq|xy/;
    return 0 if $_[0] !~ /[aeiou].*[aeiou].*[aeiou]/;
    return 1;
}

# part 2
sub nice2 {
    return 0 if $_[0] !~ /(\w\w).*\1/;
    return 0 if $_[0] !~ /(\w).\1/;
    return 1;
}
