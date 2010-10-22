use strict;
use warnings;

use Test::More tests => 8;

use Tree::Util qw(tree_filter);

my $replace = sub {
    my ($type) = ref($_[0]);
    
    if($type eq 'Regexp') {
        $_[0] = 'Regexp';
    
    } elsif($type eq 'CODE') {
        $_[0] = 'CODE';
    }
};

# Test basic stuff
is_deeply(tree_filter({ test => 1 }), { test => 1 }, "We filter hashes");
is_deeply(tree_filter([1,2,3,4]), [1,2,3,4], "We filter arrays");
is_deeply(tree_filter(\"hello"), \"hello", "We filter refs");
is_deeply(tree_filter(1), 1, "We filter scalars strings");

is_deeply(tree_filter(qr/.*/, $replace), 'Regexp', "We filter regexp");
is_deeply(tree_filter(sub { 1; }, $replace), 'CODE', "We filter coderefs");

my %hash = (
    regexp => qr/test/,
    subref => sub {},
    string => 'hello',
    number => 14,
);

is_deeply(tree_filter(\%hash, $replace), {
    regexp => 'Regexp',
    subref => 'CODE',
    string => 'hello',
    number => 14,
}, "We filter anvanced hashes");

$hash{circular} = \%hash;

my $hash2 = tree_filter(\%hash, $replace);

is_deeply($hash2, {
    regexp => 'Regexp',
    subref => 'CODE',
    string => 'hello',
    number => 14,
    circular => $hash2,
}, "We filter circular refrences");

