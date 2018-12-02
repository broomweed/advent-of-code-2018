#!/usr/bin/perl
use v5.010;

my @lines = <>;

# Part 1
{
    my $slen = 0;
    my $reallen = 0;

    my @lines = @lines;

    for (@lines) {
        chomp;

        $slen += length;

        s/\\\\/|/g;
        s/\\"/"/g;
        s/\\x(..)/chr(hex($1))/ge;
        s/^"//g;
        s/"$//g;
        $reallen += length;
    }

    say $slen - $reallen;
}

# Part 2
{
    my $slen = 0;
    my $reallen = 0;

    my @lines = @lines;

    for (@lines) {
        chomp;

        $slen += length;

        s/\\/\\\\/g;
        s/"/\\"/g;
        $_ = "\"$_\"";

        $reallen += length;
    }

    say $reallen - $slen;
}
