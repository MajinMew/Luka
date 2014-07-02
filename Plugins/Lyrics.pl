addPlug('Lyrics', {
  name => 'Lyrics Search',
  description => "This plugin was created for the Luka wiki, and isn't exactly tested. Let's just assume it works.",
  creator => 'Caaz',
  version => '1',
  modules => ['LWP::Simple'],
  dependencies => ['Fancify', 'Core_Utilities','Core_Command'],
  utilities => {
    'get' => sub {
      # Input : Artist, Track Name
      # For now, I've only done this with AZLyrics so let's just work with that.
      my @lyrics = ();
      my $search;
      # Set up search string
      if($_[0] && $_[1]) { $search = "$_[0] $_[1]"; }
      else { lkDebug("Ya dun goofed. Invalid search paremeters or something."); return 0; }
      # Grab the page.
      my $content = get("http://search.azlyrics.com/search.php?q=$search");
      my $count = 0;
      # Look for links to Lyric page.
      while($content =~ /\d+\. \<a href\=\"(.+?)\"\>(.+?)\<\/a\> by \<b\>(.+?)\<\/b\>/sg){
        my @info = ($1,$2,$3);
        if(($info[2] =~ /$_[0]/i) && ($info[1] =~ /$_[1]/i)) {
          # Push matching information into an array.
          push(@lyrics, {
            artist => $info[2],
            title => $info[1],
            url => $info[0]
          });
        }
        $count++; if($count >= 2) { last; }
      }
      # If we've got any matches, let's fill out the @lyrics array with actual lyrics! 
      foreach $lyric (@lyrics) {
        if(get(${$lyric}{url}) =~ /<\!-- start of lyrics -->(.+?)<\!/is){
          my @lines = split /\n|<br \/>/, $1;
          foreach(@lines) { s/<.+?>/\002/g; s/\r|\n//g; }
          @lines = grep !/^$/, @lines;
          push(@{${$lyric}{lyrics}},@lines);
        }
      }
      # Return our list of lyrics and stuff!
      return \@lyrics;
    },
    'show' => sub {
      # Input: Handle, Where, Lyrics Data.
      if(@{$_[2]}){
        foreach(@{$_[2]}) {
          # Title by ARTIST [url]
          &{$utility{'Fancify_say'}}($_[0],$_[1],"\x04${$_}{title}\x04 by \x04${$_}{artist}\x04 [${$_}{url}]");
          my $string = '';
          foreach(@{${$_}{lyrics}}) {
            $string .= "$_ \x04/\x04 ";
            # Cut the string off at this point, so that you aren't sending more than is possible.
            if((split //, $string) > 370) { $string =~ s/ \x04\/\x04 $//; $string .= "..."; last; }
          }
          # Show it!
          $string =~ s/ \x04\/\x04 $//;
          &{$utility{'Fancify_say'}}($_[0],$_[1],$string);
        }
      }
      else {
        &{$utility{'Fancify_say'}}($_[0],$_[1],"No lyrics found.");
      }
    },
  },
  commands => {
    '^Lyrics (.+?) - (.+)$' => {
      'tags' => ['media'],
      'description' => "Fetches lyrics from http://www.azlyrics.com",
      'code' => sub {
        my ($artist,$track) = ($1,$2);
        &{$utility{'Lyrics_show'}}($_[1]{irc}, $_[2]{where}, &{$utility{'Lyrics_get'}}($artist,$track));
      }
    }
  }
});