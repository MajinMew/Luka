addPlug('Rock',{
  'creator' => 'Caaz',
  'version' => '1',
  'description' => "More Games, they said.",
  'name' => 'Virtual Pet Rock',
  'dependencies' => ['Core_Utilities','Fancify','Core_Command','Caaz_Utilities'],
  'modules' => ['DateTime'],
  'utilities' => {
    'timer' => sub {
      foreach $serverName (keys %{$lk{data}{plugin}{'Rock'}{rocks}}) {
        foreach $channel (keys %{$lk{data}{plugin}{'Rock'}{rocks}{$serverName}}) {
          my $handle = &{$utility{'Core_Utilities_getHandle'}}($serverName);
          addTimer(time+(int(rand(300))),{'name' => 'wisdom', 'code' => sub {
            my @a = @{$_[1]}; 
            if($lk{data}{plugin}{'Rock'}{rocks}{$a[0]}{$a[1]}) {
              &{$utility{'Fancify_say'}}($a[2],$a[1],&{$utility{'Rock_getWisdom'}}($a[0],$a[1]));
            }
          }, 'args' => [$serverName,$channel,$handle]
          });
        }
      }
      &{$utility{'Rock_clearIssues'}}();
      addTimer(time+(int(rand(1000)+2000)),{'name' => 'rock', 'code' => $lk{plugin}{'Rock'}{utilities}{timer}});
    },
    'clearIssues' => sub {
      # Server Name, Channel
      foreach $serverName (keys %{$lk{data}{plugin}{'Rock'}{rocks}}) {
        foreach $channel (keys %{$lk{data}{plugin}{'Rock'}{rocks}{$serverName}}) {
          if(!(grep /$channel/, @{$lk{data}{networks}[$lk{tmp}{connection}{fileno(&{$utility{'Core_Utilities_getHandle'}}($serverName))}]{autojoin}})) {
            lkDebug("Killed $channel");
            delete $lk{data}{plugin}{'Rock'}{rocks}{$serverName}{$channel};
            next;
          }
          elsif(!$lk{data}{plugin}{'Rock'}{rocks}{$serverName}{$channel}{name}) { 
            lkDebug("Killed $channel");
            delete $lk{data}{plugin}{'Rock'}{rocks}{$serverName}{$channel};
            next;
          }
        }
      }
    },
    'protect' => sub {
      # Server Name, Channel, add how much?
      if($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}) {
        if(($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{protect}) && ($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{protect} >= time)) {
          $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{protect} += $_[2];
        }
        else {
          $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{protect} = time+$_[2];
        }
      }
    },
    'adopt' => sub {
      # Server, Handle, Where.
      if(!$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]}) {
        # No Rock exists, so create one.
        # number=1&gender=m&surname=&all=no&usage_eng=1&usage_jap=1
        #  &{$utility{'Caaz_Utilities_randName'}}();
        my %rock = ('born'=>time,'survived'=>0,'protect'=>time+10);
        if(rand > .5) {
          # Male
          $rock{gender} = "male";
          $rock{name} = &{$utility{'Caaz_Utilities_randName'}}({'number'=>1,'gender'=>'m','all'=>'no','usage_eng'=>1,'usage_jap'=>1,'usage_afr'=>1,'usage_hippy'=>1});
        }
        else {
          # Female
          $rock{gender} = "female";
          $rock{name} = &{$utility{'Caaz_Utilities_randName'}}({'number'=>1,'gender'=>'f','all'=>'no','usage_eng'=>1,'usage_jap'=>1,'usage_afr'=>1,'usage_hippy'=>1});
        }
        %{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]}} = %rock;
        &{$utility{'Fancify_say'}}($_[1],$_[2],&{$utility{'Rock_getWisdom'}}($_[0],$_[2],"Congratulations, >>home. You've just adopted >>rock. Please take care of >>genderthird, if you do, >>genderself'll live a long time! If you don't, people may try to kill >>genderthird!"));
        return 1;
      }
      else {
        # A rock exists already...
        return 0;
      }
    },
    'getWisdom' => sub {
      # Server Name, Channel, Text?
      my %rock = %{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}};
      my @wisdom;
      if($_[2]) { @wisdom = split /\s/, $_[2]; }
      else { @wisdom = split /\s/, $lk{data}{plugin}{'Rock'}{wisdom}[rand @{$lk{data}{plugin}{'Rock'}{wisdom}}];}
      my %gender;
      my $color;
      if($rock{gender} =~ /^male$/i) { $color = '12'; %gender = ('self'=>'he','selfcap'=>'He','third'=>'him','possesive'=>'his'); }
      else { $color = '13'; %gender = ('self'=>'she','selfcap'=>'She','possesive'=>'her','third'=>'her'); }
      while((join " ", @wisdom) =~ />>\w/) {
        foreach(@wisdom) {
          if(/>>rock/i) { $_ =~ s/>>rock/\x04\cC$color$rock{name} the rock\x04/ig; }
          elsif(/>>gender\w+/i){ $_ =~ s/>>gender(\w+)/$gender{$1}/ig; }
          elsif(/>>name/i) { my $name = &{$utility{'Caaz_Utilities_randName'}}(); $_ =~ s/>>name/$name/ig; }
          elsif(/>>home/i){ $_ =~ s/>>home/$_[1]/ig; }
          elsif(/>>self/i){ $_ =~ s/>>self/\x04\cC$color$rock{name}\x04/ig; }
          elsif(/>>(\w+)/) { $_ = $lk{data}{plugin}{'Rock'}{$1}[rand @{$lk{data}{plugin}{'Rock'}{$1}}]; }
        }
        my $wisdomLine = join " ", @wisdom;
        @wisdom = split /\s/, $wisdomLine;
      }
      return join " ", @wisdom;
    },
    'exists' => sub {
      # Server Name, Channel, Alert?
      # Alert 0 : Nothing
      # Alert 1 : If Doesn't exist
      # Alert 2 : If Exists
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      if($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}) {
        if(($_[2]) && ($_[2] == 1)) { &{$utility{'Fancify_say'}}($handle,$_[1],"There already exists a rock in here."); }
        return 1;
      }
      else {
        if(($_[2]) && ($_[2] == 2)) { &{$utility{'Fancify_say'}}($handle,$_[1],"There is no rock here. Get one with >>Rock."); }
        return 0;
      }
    },
    'topRocks' => sub {
      &{$utility{'Rock_clearIssues'}}();
      # Server Name, handle, Channel, type
      my @keys = ();
      if($_[3] == 1) {
        # By Protection
        @keys = sort { $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$b}{protect} <=> $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$a}{protect} } keys(%{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}});
      }
      else {
        # By Lifetime
        @keys = sort { $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$a}{born} <=> $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$b}{born} } keys(%{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}});
      } 
      my @rocks = ();
      $i = 1;
      foreach(@keys) { push(@rocks,"$i: ".&{$utility{'Rock_info'}}($_[0],$_, 2)); if($i >= 5) { last; } $i++; }
      &{$utility{'Fancify_say'}}($_[1],$_[2],"Top 5 Rocks: ".(join ", ", @rocks));
    },
    'find' => sub {
      # Server Name, Name
      foreach(keys %{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}}) { if($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_}{name} =~ /$_[1]/i) { return $_; } }
      return 0;
    },
    'info' => sub {
      # Server Name, Channel, returnType
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      my %rock = %{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}};
      my %time = ( 'born' => DateTime->from_epoch(epoch => $rock{born}), 'protection' => DateTime->from_epoch(epoch => $rock{protect}), 'now' => DateTime->now() );
      my %duration = ( 'lifetime' => $time{now}->subtract_datetime($time{born}), 'protection' => $time{protection}->subtract_datetime($time{now}) );
      my %units = ( 
        'lifetime' => [$duration{lifetime}->in_units('weeks','days','hours','minutes','seconds')], 
        'protection' => [$duration{protection}->in_units('weeks','days','hours','minutes','seconds')] 
      );
      foreach $k ('protection','lifetime') { foreach $i (2..4) { $units{$k}[$i] =~ s/-//g; while((split //, $units{$k}[$i]) <= 1) { $units{$k}[$i] = '0'.$units{$k}[$i]; } } }
      my %string = ();
      foreach('lifetime','protection') {
        $string{$_} .= "$units{$_}[0] weeks, " if(($units{$_}[0]) && ($units{$_}[0] > 1));
        $string{$_} .= "$units{$_}[0] week, " if(($units{$_}[0]) && ($units{$_}[0] == 1));
        $string{$_} .= "$units{$_}[1] days, " if(($units{$_}[1]) && ($units{$_}[1] > 1));
        $string{$_} .= "$units{$_}[1] day, " if(($units{$_}[1]) && ($units{$_}[1] == 1));
        $string{$_} .= "$units{$_}[2]:$units{$_}[3]";
        $string{$_} .= ":$units{$_}[4]" if($_[3] == 1);
      }
      if($_[2] == 1) {
        # Long
        # >>rock of >>home [Lifetime: ] [Protection: ]
        if(($rock{protect}) && ($rock{protect} > time)) { $string{protection} = "[\x04\cC09Protection: $string{protection}\x04]"; } else { $string{protection} = "[\x04\cC04Protection: 00:00:00\x04]"; }
        $string{lifetime} = "[\x04Lifetime: $string{lifetime}\x04]";
        foreach('protection','lifetime') { $string{$_} = &{$utility{'Fancify_main'}}($string{$_}); }
        return &{$utility{'Rock_getWisdom'}}($_[0],$_[1],">>rock of >>home $string{lifetime} $string{protection}");
      }
      elsif($_[2] == 2) {
        if(($rock{protect}) && ($rock{protect} > time)) { $string{protection} = " [\x04\cC09$string{protection}\x04]"; } else { $string{protection} = ""; }
        $string{lifetime} = "[\x04$string{lifetime}\x04]";
        foreach('protection','lifetime') { $string{$_} = &{$utility{'Fancify_main'}}($string{$_}); }
        return &{$utility{'Rock_getWisdom'}}($_[0],$_[1],"\">>self\" $string{lifetime}$string{protection}");
      }
      return 0;
    }
  },
  'code' => {
    'load' => sub {
      my $caught = 0;
      foreach $time (keys %{$lk{timer}}) { foreach(@{$lk{timer}{$time}}) { $caught = 1 if(${$_}{name} =~ /^rock$/i); } }
      if(!$caught) { addTimer(time+(int(rand(60)+120)),{'name' => 'rock', 'code' => $lk{plugin}{'Rock'}{utilities}{timer}}); }
    }
  },
  'commands' => {
    '^Rock(.+?) add (.*)$' => {
      'access' => 1,
      'code' => sub {
        my ($group, $line) = ($1,$2);
        $group =~ tr[A-Z][a-z];
        push(@{$lk{data}{plugin}{'Rock'}{$group}},$line);
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$group increased to >>".@{$lk{data}{plugin}{'Rock'}{$group}});
      }
    },
    '^Rock$' => {
      'tags' => ['innovative','game'],
      'description' => "Adopts a pet rock. Shows rock info if there already exists a rock.",
      'cooldown' => 5,
      'code' => sub { 
        if($_[2]{where} !~ /^\#/) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"You can't have a rock. They're channel bound!"); return 0; }
        else {
          if(!$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}) { &{$utility{'Rock_adopt'}}($_[0],$_[1]{irc},$_[2]{where}); }
          else { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_info'}}($_[0],$_[2]{where}, 1)); }
        }
      }
    },
    '^ViewRock (.+)$' => {
      'tags' => ['innovative','game'],
      'description' => "Adopts a pet rock. Shows rock info if there already exists a rock.",
      'cooldown' => 5,
      'code' => sub { 
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_info'}}($_[0],&{$utility{'Rock_find'}}($_[0],$1), 1));
      }
    },
    '^TopRocks$' => {
      'tags' => ['innovative','game'],
      'description' => "Shows top rocks.",
      'cooldown' => 5,
      'code' => sub { &{$utility{'Rock_topRocks'}}($_[0],$_[1]{irc},$_[2]{where}); }
    },
    '^TopRocks (protection|lifetime|survive)$' => {
      'tags' => ['innovative','game'],
      'description' => "Shows top rocks.",
      'cooldown' => 5,
      'code' => sub {
        my $type = $1;
        my %types = ('protection'=>1,'life'=>0,'survive'=>1);
        &{$utility{'Rock_topRocks'}}($_[0],$_[1]{irc},$_[2]{where},$types{$type}); 
      }
    },
    '^Rock (.+)$' => {
      'cooldown' => 5,
      'code' => sub {
        my $com = $1;
        if(&{$utility{'Rock_exists'}}($_[0],$_[2]{where},2)) {
          if($com =~ /^pet|pat$/i) {
            my @lines = (">>rock feels >>mood thanks to $_[2]{nickname}.", ">>rock stretches out.", ">>rock >>sound.",">>rock rolls over to reveal >>genderpossesive stomach.");
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},$lines[rand @lines]));
            &{$utility{'Rock_protect'}}($_[0],$_[2]{where},300);
          }
          elsif($com =~ /^throw (.+)/i) {
            my $target = $1;
            $target =~ s/\s$//;
            my @lines = (">>rock is flung at $target.",">>rock hits $target with the force of exactly ".(int(rand(1000)+1))." suns.",">>rock flies at $target, unwillingly.");
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},$lines[rand @lines]));
            &{$utility{'Rock_protect'}}($_[0],$_[2]{where},-(int(rand(1000))));
          }
          elsif($com =~ /^wash|bathe$/i) {
            my @lines = (">>rock >>sound.",">>rock is soaked. >>genderself looks >>mood right now.", ">>rock feels >>mood thanks to this bath!");
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},$lines[rand @lines]));
            &{$utility{'Rock_protect'}}($_[0],$_[2]{where},400);
          }
          elsif($com =~ /^feed$/i) {
            my @lines = (">>rock >>sound and eats >>food.",">>rock isn't hungry right now.", ">>rock feels >>mood now.");
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},$lines[rand @lines]));
            &{$utility{'Rock_protect'}}($_[0],$_[2]{where},600);
          }
          elsif($com =~ /^fuck|sex$/i) {
            my @lines = (">>rock says \"B-but I don't go there!\"", ">>Rock shivers at the thought", ">>Rock is too big", ">>Rock is wet", ">>rock accepts a challenge.");
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},$lines[rand @lines]));
            &{$utility{'Rock_protect'}}($_[0],$_[2]{where},int(rand(1000)+300));
          }
          elsif($com =~ /^help$/i) {
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"What can you do with your rock? Try >>Rock >>Feed, >>Rock >>Pet, >>Rock >>Throw >>TARGET, >>Rock >>Wash, or if you're a horrible person. >>Rock >>Kill");
          }
        }
      }
    },
    '^Rock help$' => { 'tags' => ['innovative','game'], 'description' => "Shows rock commands.", 'cooldown' => 5 },
    '^Rock pet$' => { 'tags' => ['innovative','game'], 'description' => "Pets the local rock.", 'cooldown' => 5 },
    '^Rock throw (.+)$' => { 'tags' => ['innovative','game'], 'description' => "Throws the local rock at someone or something.", 'cooldown' => 5 },
    '^Rock wash$' => { 'tags' => ['innovative','game'], 'description' => "Washes the local rock.", 'cooldown' => 5 },
    '^Rock kill$' => {
      'tags' => ['horrible'],
      'description' => "Kills the local pet rock. Only terrible people do this.",
      'cooldown' => 120,
      'code' => sub {
        if(&{$utility{'Rock_exists'}}($_[0],$_[2]{where})) {
          # A rock exists already...
          if(($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{protect}) && ($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{protect} >= time)) {
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},"You can't kill >>rock! >>genderself's loved!"));
          }
          else {
            if(rand > .5) {
              &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},">>rock has died. You're a terrible person."));
              delete $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}};
            }
            else {
              &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},">>rock dodges and lives to see another minute."));
              $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{survived}++;
            }
          }
        }
      }
    },
    '^Rock genocide$' => {
      'tags' => ['horrible'],
      'description' => "Kills the ALL the rocks. Only hitler does this.",
      'access' => 3,
      'code' => sub {
        foreach $serverName (keys %{$lk{data}{plugin}{'Rock'}{rocks}}) {
          foreach $channel (keys %{$lk{data}{plugin}{'Rock'}{rocks}{$serverName}}) {
            my $handle = &{$utility{'Core_Utilities_getHandle'}}($serverName);
            &{$utility{'Fancify_say'}}($handle,$channel,&{$utility{'Rock_getWisdom'}}($serverName,$channel,">>rock has died."));
            delete $lk{data}{plugin}{'Rock'}{rocks}{$serverName}{$channel};
          }
        }
      }
    }
  }
});