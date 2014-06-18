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
        foreach $regex (@{$irc{data}{ignore}}){
          #&{$lk{plugin}{'Core_Utilities'}{utilities}{debugHash}}(\%parsed);
          if($irc{msg}[0] =~ /$regex/i) {
            #lkDebug("Ignoring user.");
            return 0;
          }
        }
        return 1;
      }
      else {
        return 1;
      }
    }
  }
});
addPlug('Core_Command', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'name' => 'Core Command',
  'dependencies' => ['Core_Utilities','Core_Users'],
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG|NOTICE$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{name};
        my $prefix = $lk{data}{prefix};
        if($parsed{nickname} =~ /^$parsed{where}$/) { $prefix = $lk{data}{prefix}.'?'; }
        if($parsed{msg} =~ /^$prefix(.+)$/i) {
          my $com = $1;
          foreach $plugin (keys %{$lk{plugin}}) {
            foreach $regex (keys %{$lk{plugin}{$plugin}{commands}}) {
              if($com =~ /$regex/i) {
                if($lk{plugin}{$plugin}{commands}{$regex}{cooldown}) {
                  if(($lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{nickname}}{$regex}) && ($lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{nickname}}{$regex} > time)) {
                    lkDebug("COOLDOWN");
                    return 1;
                  }
                  else {
                    $lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{nickname}}{$regex} = time + $lk{plugin}{$plugin}{commands}{$regex}{cooldown};
                  }
                }
                if($lk{plugin}{$plugin}{commands}{$regex}{access}) {
                  my $acc = &{$lk{plugin}{'Core_Users'}{utilities}{'isLoggedIn'}}($network,$parsed{nickname});
                  if(($lk{data}{plugin}{'Core_Users'}{$network}{users}{$acc}) &&  ($lk{data}{plugin}{'Core_Users'}{$network}{users}{$acc}{access} >= $lk{plugin}{$plugin}{commands}{$regex}{access})) {
                    &{$lk{plugin}{$plugin}{commands}{$regex}{code}}($network,\%irc,\%parsed,$lk{data}{plugin}{$plugin},$lk{tmp}{plugin}{$plugin}) if($lk{plugin}{$plugin}{commands}{$regex}{code});
                  }
                  else {
                    lkRaw($irc{irc},"PRIVMSG $parsed{where} :You don't have access to this command");
                  }
                }
                else {
                  &{$lk{plugin}{$plugin}{commands}{$regex}{code}}($network,\%irc,\%parsed,$lk{data}{plugin}{$plugin},$lk{tmp}{plugin}{$plugin}) if($lk{plugin}{$plugin}{commands}{$regex}{code});
                }
              }
            }
          }
        }
      }
    },
  }
});
addPlug('Core_Help', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Core Help',
  'description' => 'This plugin was created for the usage of a help system with topics. It should be used to cover a wide arrange of topics that would be difficult to explain in command help.',
  'dependencies' => ['Core_Utilities'],
  'commands' => {
    '^Help(.+)?$' => {
      'tags' => ['utility'],
      'description' => "This command is used to show help topics. You can get more info on specific topics using this.",
    }
  },
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{name};
        if($parsed{msg} =~ /^$lk{data}{prefix}(.+)$/i) {
          my $com = $1;
          if($com =~ /^help(.+)?$/i) {
            my $helpString = $1;
            if($helpString) {
              $helpString =~ s/^\s//g;
              # Got some help string... Get more info on a command, probably.
              my $caught;
              foreach $plugin (keys %{$lk{plugin}}) {
                foreach(keys %{$lk{plugin}{$plugin}{help}}) {
                  if($helpString =~ /$_/i) {
                    $caught++;
                    lkRaw($irc{irc},"PRIVMSG $parsed{where} :$_ - $lk{plugin}{$plugin}{help}{$_}");
                  }
                }
              }
              if(!$caught) {
                lkRaw($irc{irc},"PRIVMSG $parsed{where} :No such topic found, sorry.");
              }
            }
            else {
              # No help string, list available commands?
              my @topics;
              foreach(keys %{$lk{plugin}}) {
                push(@topics, keys %{$lk{plugin}{$_}{help}});
              }
              if(!@topics) {
                lkRaw($irc{irc},"PRIVMSG $parsed{where} :There's no help topics available! Bother the owner about this.");
              }
              else {
                sort(@topics);
                lkRaw($irc{irc},"PRIVMSG $parsed{where} :Topics: ".join ", ", @topics);
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
    '^Reload$' => {
      'tags' => ['utility'],
      'description' => "Loads any new plugins, and overwrites any updated ones.",
      'access' => 3,
      'code' => sub {
        my $startTime = time;
        foreach(keys %{$lk{plugin}}) {
          &{$lk{plugin}{$_}{code}{unload}}({'data' => $lk{data}{plugin}{$_}, 'tmp' => $lk{tmp}{plugin}{$_}}) if($lk{plugin}{$_}{code}{unload});
        }
        my $errors = lkLoadPlugins();
        lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :Reloaded. (".(time - $startTime)." seconds, $errors errors)");
      }
    },
    '^Refresh$' => {
      'tags' => ['utility'],
      'description' => "Forcibly reloads all the things.",
      'access' => 3,
      'code' => sub {
        lkUnloadPlugins();
        my $errors = lkLoadPlugins();
        lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :Reloaded. (".(time - $startTime)." seconds, $errors errors)");
      }
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
        lkDebug("$_ => $lk{data}{networks}[$lk{tmp}{connection}{$_}]{name}");
      }
    }
  }
});
addPlug('Core_Users',{
  # Userbase.
  'creator' => 'Caaz',
  'version' => '1.1',
  'description' => 'This plugin was created to handle access related things. It\'s no where near as great as it should be right now.', 
  'name' => 'Core Users',
  'dependencies' => ['Core_Utilities'],
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{name};
        #foreach(keys %parsed) { print "$_ => '$parsed{$_}'\n"; }
        if($parsed{msg} =~ /^$lk{data}{prefix}(.+)$/i) {
          my $com = $1;
          if($com =~ /^Register (.+?) (.+)/i) {
            my ($account,$password) = ($1,$2);
            if(&{$lk{plugin}{'Core_Users'}{utilities}{'isLoggedIn'}}($network,$parsed{nickname})){
              lkRaw($irc{irc},"PRIVMSG $parsed{where} :You're already logged in.");
            }
            else {
              if($irc{data}{$network}{users}{$account}) {
                # Account exists
                lkRaw($irc{irc},"PRIVMSG $parsed{where} :Account already exists.");
              }
              else {
                %{$irc{data}{$network}{users}{$account}} = (
                  'name' => $parsed{nickname},
                  'password' => md5_hex(md5_hex($network.$password))
                );
                if(keys %{$irc{data}{$network}{users}} == 1) {
                  $irc{data}{$network}{users}{$account}{access} = 3;
                  lkDebug('First user created. Making owner.');
                }
                lkSave();
                $irc{tmp}{$network}{$account}{'nickname'} = $parsed{nickname};
                lkRaw($irc{irc},"PRIVMSG $parsed{where} :Successfully created user account.");
              }
            }
          }
          elsif($com =~ /^logout$/) {
            if(my $account = &{$lk{plugin}{'Core_Users'}{utilities}{'isLoggedIn'}}($network,$parsed{nickname})){
              delete $irc{tmp}{$network}{$account}{'nickname'};
              lkRaw($irc{irc},"PRIVMSG $parsed{where} :Logged out.");
            }
            else {
              lkRaw($irc{irc},"PRIVMSG $parsed{where} :You're not logged in.");
            }
          }
          elsif($com =~ /^Login (.+?) (.+)$/i) {
            my ($account,$password) = ($1,$2);
            if(&{$lk{plugin}{'Core_Users'}{utilities}{'isLoggedIn'}}($network,$parsed{nickname})){
              lkRaw($irc{irc},"PRIVMSG $parsed{where} :You're already logged in.");
            }
            else {
              if($irc{data}{$network}{users}{$account}) {
                # User account exists.
                $password = md5_hex(md5_hex($network.$password));
                #print "$irc{data}{$network}{users}{$account} =~ $password";
                if($irc{data}{$network}{users}{$account}{password} =~ /^$password$/) {
                  # Passwords match.
                  $irc{tmp}{$network}{$account}{'nickname'} = $parsed{nickname};
                  lkRaw($irc{irc},"PRIVMSG $parsed{where} :Logged in successfully.");
                }
                else {
                  lkRaw($irc{irc},"PRIVMSG $parsed{where} :Password incorrect.");
                }
              }
              else {
                lkRaw($irc{irc},"PRIVMSG $parsed{where} :No account by that name.");
              }
            }
          }
        }
      }
      #else { lkDebug($irc{msg}[1]); }
    }
  },
  'utilities' => {
    'isLoggedIn' => sub {
      # Network Name, Nickname
      foreach(keys %{$lk{tmp}{plugin}{'Core_Users'}{$_[0]}}) {
        # The keys in this should be of user account names.
        # So for everyone logged in...
        # lkDebug("Checking if $_[1] is logged into $_");
        if($lk{tmp}{plugin}{'Core_Users'}{$_[0]}{$_}{'nickname'} =~ /^$_[1]$/){
          # If their nickname is the param... Return the username!
          return $_;
        }
      }
      # If that never returns anything, return 0.
      return 0;
    }
  }
});