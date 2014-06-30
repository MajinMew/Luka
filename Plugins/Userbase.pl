addPlug('Userbase', {
  'creator' => 'Caaz',
  'version' => '1.2',
  'description' => "A replacement for Core_Users, supporting more customization, aiming towards a typical user, not just owners.",
  'name' => 'Userbase',
  'dependencies' => ['Core_Command','Core_Utilities','Digest','Fancify'],
  'utilities' => {
    'new' => sub {
      # Server, Nickname, Password
      if(&{$utility{'Userbase_isLoggedIn'}}($_[0],$_[1],2)) { return 0; }
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      my %user = (
        'name'=>$_[1],
        'created'=>time,
        'password'=>&{$utility{'Userbase_password'}}($_[2]),
        'nicknames'=>[$_[1]],
        'currently'=>$_[1],
        'access'=>0,
      );
      if(!@{$lk{data}{plugin}{'Userbase'}{users}{$_[0]}}) { $user{access} = 3; }
      push(@{$lk{data}{plugin}{'Userbase'}{users}{$_[0]}},\%user);
      &{$utility{'Fancify_say'}}($handle,$_[1],"You've made a new account with the name \x04$user{name}\x04 You are user >>".@{$lk{data}{plugin}{'Userbase'}{users}{$_[0]}}.". You have >>$user{access} access."); 
      return 1;
    },
    'login' => sub {
      # Server, Nickname, Password
      if(&{$utility{'Userbase_isLoggedIn'}}($_[0],$_[1],2)) { return 0; }
      my $match = 0;
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      foreach(@{$lk{data}{plugin}{'Userbase'}{users}{$_[0]}}) {
        if(grep /^$_[1]$/i, @{${$_}{nicknames}}) {
          $match++;
          if(&{$utility{'Userbase_password'}}($_[2]) =~ /^${$_}{password}$/i) {
            ${$_}{currently} = $_[1];
            &{$utility{'Fancify_say'}}($handle,$_[1],"You're now logged in as \x04${$_}{name}\x04. Access >>${$_}{access}."); 
            return 1; 
          }
        }
      }
      if(!$match) { &{$utility{'Fancify_say'}}($handle,$_[1],"Your nick isn't tied to any userbase accounts."); }
      else { &{$utility{'Fancify_say'}}($handle,$_[1],"Incorrect password."); }
      return 0;
    },
    'logout' => sub {
      # Server, Nickname
      if(!&{$utility{'Userbase_isLoggedIn'}}($_[0],$_[1],1)) { return 0; }
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      foreach(@{$lk{data}{plugin}{'Userbase'}{users}{$_[0]}}) {
        if((${$_}{currently}) && (${$_}{currently} =~ /^$_[1]$/i)) {
          &{$utility{'Fancify_say'}}($handle,$_[1],"You're now logged out."); 
          delete ${$_}{currently}; return 1;
        }
      }
      return 0;
    },
    'isLoggedIn' => sub {
      # Server, Nickname, Error Message?
      foreach(@{$lk{data}{plugin}{'Userbase'}{users}{$_[0]}}) { 
        if((${$_}{currently}) && (${$_}{currently} =~ /^$_[1]$/i)) { 
          &{$utility{'Fancify_say'}}(&{$utility{'Core_Utilities_getHandle'}}($_[0]),$_[1],"You're >>already logged in as \x04${$_}{name}") if(($_[2]) && ($_[2] == 2)); 
          return 1; 
        }
      }
      &{$utility{'Fancify_say'}}(&{$utility{'Core_Utilities_getHandle'}}($_[0]),$_[1],"You're >>not logged in.") if(($_[2]) && ($_[2] == 1)); 
      return 0;
    },
    'password' => sub {
      # Password
      return &{$utility{'Digest_bcrypt'}}($_[0]);
    },
    'info' => sub {
      # Server, Nicknamec
      if(!&{$utility{'Userbase_isLoggedIn'}}($_[0],$_[1])) { return {0=>0}; }
      foreach(@{$lk{data}{plugin}{'Userbase'}{users}{$_[0]}}) {
        if(grep /^$_[1]$/i, @{${$_}{nicknames}}) {
          if((${$_}{currently}) && (${$_}{currently} =~ /^$_[1]$/i)) { 
            return $_;
          }
        }
      }
      return {0=>0};
    }
  },
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      #lkDebug(join ":", @{$irc{msg}});
      #Pinochio!~Luka@Rizon-89357531.porycmtk01.res.dyn.suddenlink.net:NICK:Pino
      if($irc{msg}[1] =~ /^NICK$/i) {
        my $nickname = split /\!|\@/, $irc{msg}[0];
        foreach(@{$lk{data}{plugin}{'Userbase'}{users}{$irc{name}}}) {
          if(${$_}{currently} =~ /^$nickname$/i) { 
            push(@{${$_}{nicknames}}, $nickname);
            ${$_}{currently} = $nickname; 
          }
        }
      }
    },
  },
  'commands' => {
    '^Register (.+)$' => {
      'description' => "Registers a new userbase account.",
      'tags' => ['wip'],
      'code' => sub {
        my $password = $1;
        &{$utility{'Userbase_new'}}($_[0],$_[2]{nickname},$password);
      }
    },
    '^login (.+)$' => {
      'description' => "Logs into your userbase account",
      'tags' => ['wip'],
      'code' => sub {
        my $password = $1;
        &{$utility{'Userbase_login'}}($_[0],$_[2]{nickname},$password);
      }
    },
    '^Logout$' => {
      'description' => "Logs out of your userbase account.",
      'tags' => ['wip'],
      'code' => sub {
        &{$utility{'Userbase_logout'}}($_[0],$_[2]{nickname});
      }
    },
    '^Self$' => {
      'description' => "Views information on your userbase account.",
      'tags' => ['wip'],
      'code' => sub {
        &{$utility{'Userbase_view'}}($_[0],$_[2]{nickname});
      }
    },
  },
});