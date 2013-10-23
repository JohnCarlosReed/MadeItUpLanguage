#!/usr/bin/perl -w

# =====================================================================================
#
# This is a simple form using CGI.pm that takes a message in a textarea and creates
# a simple cryptogram.
# 
# =====================================================================================

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser); # need to upgrade CGI::Carp in order to get warningsToBrowser
use strict;
use Data::Dumper;

$| = 1; # no suffering from buffering

my $LOG = "./comments.txt";

print header,


start_html( -title=>'Roof! Roof!',
            -align=>'center' );

print br,br;

print h1('Here\'s a doggy on the roof for you...');

print p;

#print img( { src=>'../../html/images/doggyontheroof/dogontheroof.jpg', height=>'60%', width=>'60%'} );
print img( { src=>'dogontheroof.jpg', height=>'60%', width=>'60%'} );

print start_form;  


print textarea( -name=>'comment',
	        -rows=>2,
	        -columns=>50), br;

print submit( -name=>'Leave a Comment' );

print p;

print end_form;

if( param() ){

  add_comment( param( 'comment' ) );

}

show_comments();

end_html;


# -------------------------------------------------------------------------------
# Function add_comment
#   
sub add_comment {
  my $comment = shift;

  $comment =~ s/\r\n/ /g; # remove ^M from the html form.
  $comment =~ s/\|//g; # remove the character we use for the delimiter

  my $date = `date`;
  chomp $date;


  # create a pipe delimited log file of date|ip address|comment
  #
  open ( FILE, ">>$LOG" );  # don't die, let the webpage display if the log is not available for some reason
  print FILE $date;
  print FILE "|";
  print FILE $ENV{'REMOTE_ADDR'};
  print FILE "|";
  print FILE $comment;
  print FILE "\n";
  close FILE;

}

sub show_comments {

  my @tail = `tail $LOG`;
  my $line;

  foreach $line ( reverse @tail ){

    my ( $date, $ip, $comment ) = split /\|/, $line;

    print "-";
    print $comment;
    print p;
  }

}
