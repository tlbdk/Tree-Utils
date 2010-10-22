use strict;
use warnings;
use Data::Dumper; 

use Test::More tests => 9;

use Tree::Util qw(tree_merge);

my $hash = {
    test => 1,
};

my $new = tree_merge {
    $_[-1]->[0] 
} $hash, { test2 => 2 };

# Test basic stuff
is_deeply($new, { test => 1, test2 => 2 }, "We merge hashes");

my $hash1 = {
    test => {
        hello => 1,
    }
};

my $hash2 = {
    test => {
        hello2 => 2,
    }
};

print "--------------------------------\n";

$new = tree_merge { $_[-1]->[0]  } ($hash1, $hash2);

is_deeply($new, { test => { hello => 1, hello2 => 2 } }, "We merge hashes");

#print Dumper($new, $hash1, $hash2);

# Should i keep left side? only if left is defined
is_deeply((tree_merge { 
    defined $_[0] 
} [10], [1, 3, 4, 5]), [10, 3, 4, 5], 
   "We keep first if defined");

# Should i keep left side? only if left is defined
is_deeply((tree_merge { 
    defined $_[0] 
} [10, {}], [1, 3, 4, 5]), [10, {}, 4, 5], 
    "We keep first if defined and hash");

# Should i keep left side? only if left side exists  
is_deeply((tree_merge { 
    $_[-1]->[0] 
} [10, undef], [1, 3, 4, 5]), [10, undef, 4, 5], 
    "We keep first if defined and handle undef");

# Should i keep left side? only if right side exists  
is_deeply((tree_merge { 
    $_[-1]->[1] 
} [10, 2], [1, 3, 4, 5]), [10, 2], 
    "Only take the first array");

# Should i keep left side? not if right side exists 
is_deeply((tree_merge { 
    !$_[-1]->[1] 
} [10, 2], [1, 3, 4, 5]), [1, 3, 4, 5], 
    "Only take the second array");

# Should i keep left side? only if left and right side exists  
is_deeply((tree_merge { 
    !$_[-1]->[0] and $_[-1]->[1];
} [10, 2], [1, 3, 4, 5]), [1, 3], 
    "Overwrite values but only length of first array");

is_deeply((tree_merge { 
    my $res = (!$_[-1]->[0] and $_[-1]->[1]);
    #print Dumper($res, \@_);
    $res;
} [10, 2], [1, 3, 4, 5]), [1, 3], 
    "Overwrite values but only length of first array");

exit;

# experimental 
use List::Util qw(max min);

my @trees = ([11,12,13], [21, 22, 23,], [31, 32, 34]);

is_deeply((tree_merge { 
    max($_[-1])
} @trees), 
    "Always use the right most values that exists");

is_deeply((tree_merge { 
    min($_[-1])
} @trees), 
    "Always use the left most values that exists");



