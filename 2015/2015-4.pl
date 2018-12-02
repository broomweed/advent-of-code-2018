#!/usr/bin/perl
use Digest::MD5 qw(md5);
use v5.010;

for (my $i = 0; ; $i++) {
    $hash = unpack "H*", md5("ckczppom$i");
    die "ckczppom$i => $hash\n" if $hash =~ /^0{$ARGV[0]}.+/;
}
