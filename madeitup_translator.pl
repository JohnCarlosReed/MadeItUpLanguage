#!/usr/bin/perl -w

# =====================================================================================
# This is a CGI program that displays a textbox for folks to enter in text that
# gets translated into a language that I made up.  The language is stored in a pipe
# delimited dictionary text file. 
# =====================================================================================

use CGI qw/:standard/;

use strict;

print header,

      start_html( -title=>'Johnny Carlos Language Inventor',
                  -align=>'center' ),

      br,br, 

      h1('Made It Up - Language Translator'),

      "Questions or suggestions:  johnnycarlos\@gmail.com",

      p,

      start_form,

      textarea( -name=>'to_translate',
                -default=>'The coldest winter I ever spent was a summer in San Francisco.',
	        -rows=>10,
	        -columns=>50),
      br,

      submit( -name=>'submit',
              -value=>'Generate'),

      p,

      end_form;


if( param( 'to_translate' ) ){

  my $string = param( 'to_translate' );

  my $translation = translate( $string );

  print h3( $translation );

  print_to_log( $translation );

}

print end_html;

# =======================================================================
# This subroutines opens up a dictionary file and stores all the words
# in a hash reference.  It takes a string input, then replaces the
# words in the string with the definition of any matching work in the
# dictionary hash reference
#
sub translate {

  my $string = lc shift;

  open( DICT, "< crazy.dict") or die "Could not open dictionary: $!\n";

  my $dictionary = get_dictionary();

  foreach( keys %$dictionary ){

    my $word = $_;

    $string =~ s/\b$word\b/$dictionary->{ $word }/g;

    $string =~ s/\n/<br \/>/g;

  }

  return $string;

}


sub get_dictionary {

  my ($dict, $word, $definition);

  while ( <DICT> ){

    ($word, $definition) = split /\|/,$_;

    chomp $definition;

    $dict->{$word} = $definition;
  }

  close DICT;

  return $dict; 

}

sub print_to_log {

  my $string = shift;

  open( LOG, ">>/var/www/logs/crazylang.log" );
  print LOG `date`;
  print LOG remote_host();
  print LOG "\n";
  print LOG $string;
  print LOG "\n";
  print LOG "=" x 20;
  print LOG "\n";
  close LOG;

}
