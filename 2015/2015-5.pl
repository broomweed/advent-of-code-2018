#!/usr/bin/perl
use v5.010;

@strings = <>;

for (@strings) {
    $nice ++ if nice($_);
}

say $nice;

for (@strings) {
    $nice2 ++ if nice2($_);
}

say $nice2;

sub nice {
    # whoa, dynamic scoping! :/
    return 0 if $_ !~ /(\w)\1/;
    return 0 if /ab|cd|pq|xy/;
    return 0 if $_ !~ /[aeiou].*[aeiou].*[aeiou]/;
    return 1;
}

sub nice2 {
    return 0 if $_ !~ /(\w\w).*\1/;
    return 0 if $_ !~ /(\w).\1/;
    return 1;
}
