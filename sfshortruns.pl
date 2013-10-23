#!/usr/bin/perl -w

use strict;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser); # need to upgrade CGI::Carp in order to get warningsToBrowser
use LWP::UserAgent;
use Data::Dumper;


print header;

print start_html('Cool Art Films'),
    h1('Short Run Films (San Francisco Only)'),
    p,
    hr;

my @short_runs = get_short_runs();
print foreach ( @short_runs );
print end_html;


sub get_short_runs {

  my ( @links, @local_shows );
  my $domain = "www.sfgate.com";
  my $path    = "/eguide/arts/lists/moviesShortRuns.html";

  my $ua = new LWP::UserAgent;

  $ua->agent("AgentName/0.1 " . $ua->agent);

  my $req = new HTTP::Request GET => "http://$domain$path";

  $req->content_type('application/x-www-form-urlencoded');

  $req->content('match=www&errors=0');

  my $res = $ua->request($req);

  #
  # Open up the short runs movie index frame, 
  # LWP the contents of each link and
  # return only local shows
  #  
  if ($res->is_success) {

      my @lines = split /\n/, $res->content;
      #print Dumper @lines; 

      foreach ( @lines ){
        if ( /<A HREF=\"(.*?)\">(.*?)<\/A>/ ) {
          #print $1 . "\n";
          my $local_show = get_if_local_show( $domain, $1 ); 
          push @local_shows, $local_show if $local_show;
        }
      }

  }
  else {
    croak "Short Runs Main Page Loaded Incorrectly";
  }

  return @local_shows;
}

sub get_if_local_show {

  my ( $domain, $path ) = @_; 

  my $ua = new LWP::UserAgent;

  $ua->agent("AgentName/0.1 " . $ua->agent);

  my $req = new HTTP::Request GET => "http://$domain$path";

  $req->content_type('application/x-www-form-urlencoded');

  $req->content('match=www&errors=0');

  my $res = $ua->request($req);

  my $content;

  if ($res->is_success) {
      $content = $res->content;
      return undef if $content =~ /Berkeley, CA/i;
      return undef if $content =~ /San Rafael, CA/i;
      return undef if $content =~ /Oakland, CA/i;
      return undef if $content =~ /Napa, CA/i;
  }
  else{
    carp  "Error Loading Local Show\n";
    print "Error Loading Local Show\n";
  }




  #
  # scrape the contents of <BODY>
  #
  # here is the html for the movie title: <!--MOVIE_NAME-->THE AMERICAN ASTRONAUT<!----> 
  
  if( $content =~ /<body(.*?)>(.*)<\/body>/si ) {  # needed to add /s so that . matches newlines!!!
    my $body = $2; 
    $body =~ s/A HREF=\"(.*)Full Review/A HREF=\"http:\/\/$domain$1Full Review/;
    #$body =~ s/IMG SRC=\"/IMG SRC=\"http:\/\/$domain/;
    #$body =~ s/IMG SRC=\"/IMG SRC=\"http:\/\/$domain/;

    #$body =~ s/<!--MOVIE_NAME-->(.*?)<!---->/$imdb_link->($1)/;

    return $body;
  }
  else {
    carp  "They made an html change, those rat bastards!\n";
    print "They made an html change, those rat bastards!\n";

  }
}


#
# used a begin block otherwise this sub MUST be defined before everything else 
my $imdb_link;
BEGIN{ 

  $imdb_link = sub {
    my $movie_title = shift;

    my $link = "<A HREF=\"http://us.imdb.com/Find?select=Title&for=";
    $link .=  CGI->escape($movie_title); 
    $link .=  "\">";
    $link .= $movie_title; 
    $link .= "</A>\n";

    return ($link);

  };

}
