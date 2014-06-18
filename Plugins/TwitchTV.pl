addPlug("TwitchTV",{
  'creator' => 'RePod',
  'version' => '1',
  'name' => 'TwitchTV Status',
  'dependencies' => ['Fancify','Core_Utilities'],
  'modules' => ['LWP::Simple'],
  'description' => "Display information about TwitchTV streams either manually by name or automatically by URL.",
  'utilities' => {
    'twitchify' => sub {
      # input: name, return: status
      # TODO: JSON maybe? Work out better variable management.
      ($twitch_title,$twitch_stream_type,$twitch_channel_count,$twitch_status,$twitch_meta_game) = ($_[0],"?","?","?","?");
      my @temp = split(/\n/, get("http://api.justin.tv/api/stream/list.xml?channel=$twitch_title"));
      @keep = [];
      foreach (@temp) {
        my $r = /\<(\w+)\>(.+?)\<\/(\w+)\>/;
        my $s = "twitch_".$1;
        if (${$s}) {
          push @keep, $s;
          ${$s} = $2;
        }
      }
      my $s = "";
      if ($twitch_stream_type ne "?") {
        $s = "[\x04$twitch_channel_count\x04] $twitch_status [\x04$twitch_meta_game\x04] [ http://twitch.tv/\x04$twitch_title\x04 ]";
      } else {
        $s = "\x04$twitch_title\x04 is offline. [\x04According to the API\x04] [ http://twitch.tv/\x04$twitch_title\x04 ]";
      }
      foreach (@keep) { undef ${"$_"}; } undef @keep;
      return $s;
    }
  },
  'commands' => {
    '^Twitch (\w+)$' => {
      'tags' => ['media'],
      'description' => "Display information about TwitchTV streams manually.",
      'example' => "twitch twitch",
      'code' => sub {
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'TwitchTV_twitchify'}}("$1"));		
      }
    },
  },
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG|NOTICE$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        if($parsed{msg} =~ /twitch\.tv\/\w+/i) {
         foreach($parsed{msg} =~ /twitch\.tv\/(\w+)/g) {
            &{$utility{'Fancify_say'}}($irc{irc},$parsed{where},&{$utility{'TwitchTV_twitchify'}}("$1"));
          }
        }
      }
    }
  }
});