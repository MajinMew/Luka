addPlug("TwitchTV",{
  'creator' => 'RePod',
  'version' => '1',
  'name' => 'TwitchTV Status',
  'dependencies' => ['Fancify','Core_Utilities'],
  'modules' => ['LWP::Simple'],
  'description' => "Display information about TwitchTV streams either manually by name or automatically by URL.",
  'utilities' => {
    'info' => sub {
      # Input: FileHandle, Where, Twitch User
      # Output: Boolean (streaming/notstreaming)
      my $user = $_[2];
      my $json = get('http://api.justin.tv/api/stream/list.json?channel='.$user);
      $json =~ s/^\[|\]$//g;
      my %twitch;
      eval { %twitch = %{decode_json($json)}; };
      if($@) { &{$utility{'Fancify_say'}}($_[0],$_[1],">>$user is offline. [\x04According to the API\x04] [http://twitch.tv/$user]"); return 0; }
      else {
        &{$utility{'Fancify_say'}}($_[0],$_[1],"[>>$twitch{channel_count}] $twitch{title} [\x04$twitch{meta_game}\x04] [http://twitch.tv/$user]");
        return 1;
      }
    },
  },
  'commands' => {
    '^Twitch (\w+)$' => {
      'tags' => ['media', 'utility'],
      'description' => "Display information about TwitchTV streams manually.",
      'example' => "twitch twitch",
      'code' => sub {
        &{$utility{'TwitchTV_info'}}($_[1]{irc},$_[2]{where},$1);	
      }
    },
  },
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG|NOTICE$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        foreach($parsed{msg} =~ /twitch\.tv\/(\w+)/g) {
          &{$utility{'TwitchTV_info'}}($irc{irc},$parsed{where},$_);
        }
      }
    }
  }
});