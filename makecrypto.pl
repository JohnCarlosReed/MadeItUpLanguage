#!/usr/bin/perl -w

# =====================================================================================
#
# This is a simple form using CGI.pm that takes a message in a textarea and creates
# a simple cryptogram.
# 
# =====================================================================================

use CGI qw/:standard/;

use strict;

print header,


start_html( -title=>'Simple Cryptogram Generator',
            -align=>'center' );

print br,br;

print h1('Cryptogram Generator');

print "Questions or suggestions:  johnnycarlos\@gmail.com";

print p;

print start_form;  

print textarea( -name=>'to_encrypt',
                -default=>'Enter text to make crypto!',
	        -rows=>10,
	        -columns=>50), br;

print submit( -name=>'submit',
              -value=>'Generate');

print p;

print end_form;

if( param() ){

  my $encrypted_text = encrypt( param( 'to_encrypt' ) );

  print ( $encrypted_text );

}

end_html;


# -------------------------------------------------------------------------------
# Function encrypt
#   This function takes a string and returns a simple cryptogram in uppercase.
#   Any character not part of the alphabet is left in place
#
sub encrypt {

  my $text = uc( shift );

  my @randomized_alphabet = ( 'A'..'Z');

  shuffle( \@randomized_alphabet );

  my $crypto_key;  #hash ref, keys = alphabet, values=random letters

  # Create the cryptogram key, foreach letter in the alphabet add to hash the
  # letter as the key, and a random letter as the value
  foreach( 'A'..'Z' ){

    my $random_char = pop @randomized_alphabet;

    $crypto_key->{$_}  = $random_char;
  }

  my $encrypted_string = "";


  # Go through each character of the input text, look it up in the crypto_key
  # hash and build a new string
  foreach( split //, $text ){
    
    # If a char is not in the alphabet(like space, numbers, apostrophes),
    # just leave it alone but add it to the encrypted_string
    if ( not defined $crypto_key->{ $_ } ){
      $encrypted_string .= $_;
      next;
    }

    $encrypted_string .= $crypto_key->{ $_ };
  }

  return $encrypted_string;

}

#-----------------------------
# fisher_yates_shuffle( \@array ) : generate a random permutation
# of @array in place
#
sub shuffle {

    my $array = shift;
    my $i;

    # I borrowed this from the Cookbook, from what I can tell, it takes a number
    # the size of the array, then creates a random number with that length and
    # switches those two elements of the array.  The index is then decremented,
    # that's probably what makes it random since it's not continually calling
    # rand on the same number(length) 

    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}

