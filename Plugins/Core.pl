addPlug('Core_Ignore', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Core Ignore',
  'description' => "This plugin sets up a way to ignore problem users.",
  'dependencies' => ['Core_Utilities'],
  'code' => {
    'pre' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG|NOTICE$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{name};
        foreach $regex (@{$irc{data}{ignore}}){ if($irc{msg}[0] =~ /$regex/i) { return 0; } }
        return 1;
      }
      else { return 1; }
    }
  }
});
addPlug('Core_Command', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'name' => 'Core Command',
  'dependencies' => ['Core_Utilities','Userbase','Fancify'],
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG|NOTICE$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{name};
        my $prefix = $lk{data}{prefix};
        my $type = 'public';
        if($parsed{nickname} =~ /^$parsed{where}$/) { $type = 'private'; $prefix = $lk{data}{prefix}.'?'; }
        if($parsed{msg} =~ /^$prefix(.+)$/i) {
          my $com = $1;
          foreach $plugin (keys %{$lk{plugin}}) {
            foreach $regex (keys %{$lk{plugin}{$plugin}{commands}}) {
              if($com =~ /$regex/i) {
                my %command = %{$lk{plugin}{$plugin}{commands}{$regex}};
                if($command{cooldown}) {
                  if(($lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{username}}{$regex}) && ($lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{username}}{$regex} > time)) { return 1; }
                  else { $lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{username}}{$regex} = time + $lk{plugin}{$plugin}{commands}{$regex}{cooldown}; }
                }
                if($command{access}) {
                  my %account = %{$utility{'Userbase_info'}($network,$parsed{nickname})};
                  if(($account{access}) && ($account{access} >= $command{access})) {
                    &{$command{code}}($network,\%irc,\%parsed,$lk{data}{plugin}{$plugin},$lk{tmp}{plugin}{$plugin}) if($command{code});
                  }
                  else { &{$utility{'Fancify_say'}}($irc{irc},$parsed{where},"You don't have enough >>access for this command."); }
                }
                else { &{$command{code}}($network,\%irc,\%parsed,$lk{data}{plugin}{$plugin},$lk{tmp}{plugin}{$plugin}) if($command{code}); }
              }
            }
          }
        }
      }
    },
  }
});
addPlug('Core_CTCP', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Core CTCP',
  'dependencies' => ['Core_Utilities'],
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        if($parsed{msg} =~ /\x01(.+)\x01/i) {
          my $ctcp = $1;
          if($ctcp =~ /^VERSION$/i) { lkRaw($irc{irc},"NOTICE $parsed{nickname} :VERSION $lk{version} ($lk{os})"); }
          elsif($ctcp =~ /^TIME$/i) { lkRaw($irc{irc},"NOTICE $parsed{nickname} :TIME ".localtime); }
          elsif($ctcp =~ /^FINGER$/i) { lkRaw($irc{irc},"NOTICE $parsed{nickname} :FINGER Oh god yes"); }
          elsif($ctcp =~ /^PING$/i) { lkRaw($irc{irc},"NOTICE $parsed{nickname} :PING PONG"); }
        }
      }
    }
  }
});
addPlug('Core_Owner',{
  'creator' => 'Caaz',
  'version' => '1.1',
  'name' => 'Core Owner',
  'description' => 'This plugin handles commands that should only be available to the owner.',
  'dependencies' => ['Core_Ignore','Core_Command'],
  'commands' => {
    '^End$' => {
      'tags' => ['utility'],
      'description' => "Closes Luka.",
      'access' => 3,
      'code' => \&lkEnd
    },
    '^Autojoin (\#.+)$' => {
      'tags' => ['utility'],
      'description' => "Adds or removes channels from autojoin.",
      'access' => 2,
      'code' => sub {
        my $channel = $1;
        my $i = 0; 
        my $deleted = 0;
        foreach(@{$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}}) {
          if($_ =~ /^$channel$/i) {
            lkRaw($_[1]{irc},"PART ".$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}[$i]);
            delete $lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}[$i];
            $deleted = 1;
          }
          $i++;
        }
        if($deleted) {
          @{$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}} = grep(!/^$/, @{$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}});
          lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :Removed channel from autojoin");
        }
        else {
          push(@{$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}}, $channel);
          lkRaw($_[1]{irc},"JOIN $channel");
          lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :Added channel to autojoin");
        }
      }
    },
    '^\!(.+)$' => {
      'tags' => ['utility'],
      'description' => "Executes perl code.",
      'access' => 3,
      'code' => sub {
        my $code = $1;
        my @result = split /\n|\r/, eval $code;
        if($@) { lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :".(join "\|", split /\r|\n/, $@)); }
        else { lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :".(join "\|", @result)); }
      }
    },
    '^Ignore (.+?)( .+)?$' => {
      'tags' => ['utility'],
      'description' => "Handles ignoring users this works globally, spheal with it.",
      'access' => 3,
      'code' => sub {
        my ($com,$string) = ($1,$2);
        if($string) { $string =~ s/^\s//g;}
        if(($com =~ /add/i) && ($string)) {
          push(@{$lk{data}{plugin}{"Core_Ignore"}{ignore}}, $string);
          lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :Added \[$string\] to the ignore list.");
        }
        elsif(($com =~ /del/i) && ($string)) {
          my $position = 0; my @catch;
          foreach $regex (@{$lk{data}{plugin}{"Core_Ignore"}{ignore}}){
            if($string =~ /$regex/i) { push(@catch, $position); }
            $position++;
          }
          foreach(@catch) { delete $lk{data}{plugin}{"Core_Ignore"}{ignore}[$_]; }
          @{$lk{data}{plugin}{"Core_Ignore"}{ignore}} = grep(!/^$/, @{$lk{data}{plugin}{"Core_Ignore"}{ignore}});
          lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :Removed ".(@catch+0)." ignores matching $string");
        }
        elsif(($com =~ /list/i) && (!$string)) {
          lkRaw($_[1]{irc}, "PRIVMSG $_[2]{where} :\[".(join "\] \[", @{$lk{data}{plugin}{"Core_Ignore"}{ignore}})."\]");
        }
        else {
          lkRaw($_[1]{irc}, "PRIVMSG $_[2]{where} :You're doing something wrong here.");
        }
      }
    }
  }
});
addPlug('Core_Utilities',{
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Core Utilities',
  'code' => {
    'load' => sub {
      %utility = ();
      # Throw all utilities into %utilities!
      foreach $plugin (keys %{$lk{plugin}}) {
        foreach $utilityName (keys %{$lk{plugin}{$plugin}{utilities}}) {
          $utility{$plugin.'_'.$utilityName} = $lk{plugin}{$plugin}{utilities}{$utilityName};
        }
      }
      #&{$utility{'Core_Utilities_debugHash'}}(\%utility);
    }
  },
  'utilities' => {
    'uniq' => sub { my %seen; grep !$seen{$_}++, @_ }, # I can't take any credit for this, but it is fucking beautiful.
    'debugHash' => sub {
      # Input: \%hash;
      my %hash = %{ shift(); };
      lkDebug("DEBUG");
      my @keys = keys %hash; @keys = sort @keys;
      foreach(@keys) { lkDebug("$_ => $hash{$_}"); }
    },
    'parse' => sub {
      # Input: @Msg
      # Output: nickname, username, host, msg, where
      my %return;
      #Confs!~Confs@such.strange.wow : PRIVMSG : #yugibro : >read review
      ($return{nickname}, $return{username}, $return{host}) = split/\!|\@/, $_[0];
      if($_[2] =~ /^\#/) { $return{where} = $_[2]; }
      else { $return{where} = $return{nickname}; }
      ($return{msg} = $_[3]) =~ s/\003\d{1,2}(?:\,\d{1,2})?|\02|\017|\003|\x16|\x09|\x13|\x0f|\x15|\x1f//g;
      chomp($return{msg});
      return \%return;
    },
    'getHandle' => sub {
      # Get Handle from network name.
      # Input -> Network name
      foreach(keys %{$lk{tmp}{connection}}) {
        if($lk{data}{networks}[$lk{tmp}{connection}{$_}]{name} =~ /^$_[0]$/i) {
          return $lk{tmp}{filehandles}{$_};
        }
      }
    },
    'shuffle' => sub { my $deck = shift; return unless @$deck; my $i = @$deck; while (--$i) { my $j = int rand ($i+1); @$deck[$i,$j] = @$deck[$j,$i]; } }
  }
});