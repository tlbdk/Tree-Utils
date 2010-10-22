package Tree::Util;
use strict;
use warnings;
use Carp;

use List::Util qw(max);
use Data::Dumper;

our $VERSION = '0.1';

use base "Exporter";

=head1 NAME

Tree::Util - A module to make manipulation of tree like structures easy. All
done without recursion.

=head1 DESCRIPTION

This module tries to simplify the process of dealing with trees in Perl.

=head1 SYNOPSIS
  
  use Tree::Util;

=head1 METHODS

=over

=cut

our @EXPORT = qw(tree_filter tree_merge);

=item tree_merge($base, $new, $before, $after)

Merge $base and $new, overwriting $base with new.

=cut

sub tree_merge(&@) {
    my ($callback, @trees) = @_;
    my $result;

    my %refs;

    my @walk = ([ map { \$_ } @trees ]);
    while(my $left = shift @walk) {
        my $right; 
      
        ($left, $right) = @{$left} if ref $left eq 'ARRAY'; 
       
        # Get the type of the object 
        my $type = ref($$left);

        if($$left and exists $refs{$$left}) {
            $$left = $refs{$$left}; # Handle cicular refrences
        
        } elsif ($type eq 'SCALAR' or $type eq '') {
            # IGNORE - just a simple copy done by HASH, ARRAY or last code
    
        } elsif ($type eq 'HASH') { # Hash
            $$left = $refs{$$left} = {%{$$left}};  # Copy the hash, save old ref

            # Loop over $new hash and add keys to $obj
            my @keys = keys %{{map {$_ => 1} keys %{$$left}, keys %{$$right}}};
            foreach my $key (@keys) {
                my $ref1 = ref $$left->{$key};
                my $ref2 = ref $$right->{$key};
               
                if($ref1 eq $ref2 and $ref1 eq 'HASH' or $ref1 eq 'ARRAY') {
                    push(@walk, [ \$$left->{$key}, \$$right->{$key} ]);
                
                # Ask callback if it's tree1 or tree2 we should use
                } elsif(!$callback->($$left->{$key}, $$right->{$key}, 
                        [exists $$left->{$key}, exists $$right->{$key}])) {
                   
                    # Replace key if right exists
                    if(exists $$right->{$key}) {
                        $$left->{$key} = $$right->{$key};
                        push(@walk, \$$left->{$key});
                   
                    # Else delete as we can't replace with non existing key
                    } else {
                        delete $$left->{$key};
                    }
                }
            }
        
        } elsif ($type eq 'ARRAY') { # Array
            $$left = $refs{$$left} = [@{$$left}];  # Copy the array, save old ref

            my $i;
            for ($i = 0; $i < max(int @{$$right}, int @{$$left}); $i++) {     
                my $ref1 = ref $$left->[$i];
                my $ref2 = ref $$right->[$i];
                
                if($ref1 eq $ref2 and $ref1 eq 'HASH' or $ref1 eq 'ARRAY') {
                    push(@walk, [ \$$left->[$i], \$$right->[$i], 'test']);
                
                # Ask callback if it's tree1 or tree2 we should use
                } elsif(!$callback->($$left->[$i], $$right->[$i], 
                        [exists $$left->[$i], exists $$right->[$i]])) {
                    $$left->[$i] = $$right->[$i];
                    push(@walk, \$$left->[$i]);
                }
            }
        
        } else {
            croak "unhandled type: $type";
        }
        
        # Make sure we make a ref to the first we are working with
        $result = $$left if !defined $result; 
    }
    
    #use Data::Dumper; print Dumper($args);
    return $result;
}


=item tree_filter($tree, $before, $after)

Make a copy of $tree running the code in $before before default handling and
$after after.

=cut

sub tree_filter {
    my ($args, $before, $after) = @_;
    my $result;

    my %refs;

    my @walk = (\$args);
    while(my $obj = shift @walk) {
        my $type = ref($$obj);

        if($before and $before->($$obj, \%refs)) {
            # Handled by filter - do nothing 
   
        } elsif($$obj and exists $refs{$$obj}) {
            $$obj = $refs{$$obj}; # Handle cicular refrences
        
        } elsif ($type eq 'SCALAR' or $type eq '') {
            # IGNORE - just a simple copy
    
        } elsif ($type eq 'HASH') { # Hash
            $$obj = $refs{$$obj} = {%{$$obj}};  # Copy the hash, save old ref
            push(@walk, map { \$_ } values %{$$obj});
        
        } elsif ($type eq 'ARRAY') { # Array
            $$obj = $refs{$$obj} = [@{$$obj}];  # Copy the array, save old ref
            push(@walk, map { \$_ } @{$$obj});
        
        } elsif($after and $after->($$obj, \%refs)) {
            # Handled by filter - do nothing 
        
        } else {
            croak "unhandled type: $type";
        }
        
        # Make sure we make a ref to the first we are working with
        $result = $$obj if !defined $result; 
    }
    
    #use Data::Dumper; print Dumper($args);
    return $result;
}


=back

=cut

=head2 NOTES

=cut

=head1 AUTHOR

Troels Liebe Bentsen <troels@it-kartellet.dk>

=head1 COPYRIGHT AND LICENCE

Copyright 2009: Troels Liebe Bentsen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
