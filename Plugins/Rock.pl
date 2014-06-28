addPlug('Rock',{
  'creator' => 'Caaz',
  'version' => '1',
  'description' => "More Games, they said.",
  'name' => 'Virtual Pet Rock',
  'dependencies' => ['Core_Utilities','Fancify','Core_Command','Caaz_Utilities'],
  'modules' => ['DateTime','DateTime::TimeZone'],
  'utilities' => {
    'timer' => sub {
      foreach $serverName (keys %{$lk{data}{plugin}{'Rock'}{rocks}}) {
        foreach $channel (keys %{$lk{data}{plugin}{'Rock'}{rocks}{$serverName}}) {
          my $handle = &{$utility{'Core_Utilities_getHandle'}}($serverName);
          lkDebug("Setting a wisdom.");
          addTimer(time+(int(rand(120))),{'name' => 'wisdom', 'code' => sub {
            my @a = @{$_[1]}; 
            if($lk{data}{plugin}{'Rock'}{rocks}{$a[0]}{$a[1]}) {
              &{$utility{'Fancify_say'}}($a[2],$a[1],&{$utility{'Rock_getWisdom'}}($a[0],$a[1]));
            }
          }, 'args' => [$serverName,$channel,$handle]
          });
        }
      }
      &{$utility{'Rock_clearIssues'}}();
      addTimer(time+(int(rand(1000)+1000)),{'name' => 'rock', 'code' => $lk{plugin}{'Rock'}{utilities}{timer}});
    },
    'clearIssues' => sub {
      # Server Name, Channel
      foreach $serverName (keys %{$lk{data}{plugin}{'Rock'}{rocks}}) {
        foreach $channel (keys %{$lk{data}{plugin}{'Rock'}{rocks}{$serverName}}) {
          if(!(grep /$channel/, @{$lk{data}{networks}[$lk{tmp}{connection}{fileno(&{$utility{'Core_Utilities_getHandle'}}($serverName))}]{autojoin}})) {
            lkDebug("Killed $channel");
            delete $lk{data}{plugin}{'Rock'}{rocks}{$serverName}{$channel};
          }
          elsif(!$lk{data}{plugin}{'Rock'}{rocks}{$serverName}{$channel}{name}) { 
            lkDebug("Killed $channel");
            delete $lk{data}{plugin}{'Rock'}{rocks}{$serverName}{$channel};
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
        my %rock = ('born'=>time,'survived'=>0);
        if(rand > .5) {
          # Male
          $rock{gender} = "male";
          $rock{name} = &{$utility{'Caaz_Utilities_randName'}}({'number'=>1,'gender'=>'m','all'=>'no','usage_eng'=>1,'usage_jap'=>1,'usage_afr'=>1});
        }
        else {
          # Female
          $rock{gender} = "female";
          $rock{name} = &{$utility{'Caaz_Utilities_randName'}}({'number'=>1,'gender'=>'f','all'=>'no','usage_eng'=>1,'usage_jap'=>1,'usage_afr'=>1});
        }
        %{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]}} = %rock;
        &{$utility{'Fancify_say'}}($_[1],$_[2],&{$utility{'Rock_getWisdom'}}($_[0],$_[2],"Congratulations, $_[2]. You've just adopted >>rock. Please take care of >>genderthird."));
        return 1;
      }
      else {
        # A rock exists already...
        return 0;
      }
    },
    'getWisdom' => sub {
      # Server Name, Channel, Text?
      my @wisdom;
      if($_[2]) { @wisdom = split /\s/, $_[2]; }
      else { @wisdom = split /\s/, $lk{data}{plugin}{'Rock'}{wisdom}[rand @{$lk{data}{plugin}{'Rock'}{wisdom}}];}
      my %gender;
      if($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{gender} =~ /^male$/i) { %gender = ('self'=>'he','selfcap'=>'He','third'=>'him','possesive'=>'his'); }
      else { %gender = ('self'=>'she','selfcap'=>'She','possesive'=>'her','third'=>'her'); }
      while((join " ", @wisdom) =~ />>\w/) {
        foreach(@wisdom) {
          if(/>>rock/i) {
            my $color; if($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{gender} =~ /^m/i) { $color = '12'; } else { $color = '13'; }
            $_ =~ s/>>rock/\x04\cC$color$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{name} the rock\x04/ig;
          }
          elsif(/>>gender\w+/){ $_ =~ s/>>gender(\w+)/$gender{$1}/ig; }
          elsif(/>>name/) { my $name = &{$utility{'Caaz_Utilities_randName'}}(); $_ =~ s/>>name/$name/ig; }
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
      # Server Name, handle, Channel
      my @keys = sort { $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$a}{born} <=> $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$b}{born} } keys(%{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}});
      my @rocks = ();
      $i = 1;
      my $tz = DateTime::TimeZone->new( name => 'local' );
      my $dt = DateTime->now();
      foreach(@keys) {
        my %rock = %{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_}};
        my $color; if($rock{gender} =~ /^m/i) { $color = '12'; } else { $color = '13'; }
        
        my $adopt = DateTime->from_epoch(epoch => $rock{born});
        my $duration = $dt->subtract_datetime($adopt);
        my @dur = $duration->in_units('days','hours','minutes');
        my $durationString;
        $durationString .= "$dur[0] days, " if($dur[0]);
        foreach(1,2) { while((split //, $dur[$_]) <= 1) { $dur[$_] = '0'.$dur[$_]; } }
        $durationString .= "$dur[1]:$dur[2]";
        if(($rock{protect}) && ($rock{protect} > time)) {
          $durationString .= " (\x04\cC09".($rock{protect}-time)."\x04)";
        }
        elsif(($rock{protect}) && ($rock{protect} <= time)) {
          $durationString .= " (\x04\cC04".($rock{protect}-time)."\x04)";
        }
        else {
          $durationString .= " (\x04\cC040\x04)";
        }
        push(@rocks,"[>>$i:$_ \"\x04\cC$color$rock{name}\x04\" $durationString]");
        if($i >= 5) { last; }
        $i++;
      }
      &{$utility{'Fancify_say'}}($_[1],$_[2],"There are currently >>".@keys." rocks. Here are the top 5: ".(join " ", @rocks));
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
        if(!$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}) {
          # No Rock exists
          &{$utility{'Rock_adopt'}}($_[0],$_[1]{irc},$_[2]{where});
        }
        else {
          # A rock exists already...
          my $tz = DateTime::TimeZone->new( name => 'local' );
          my $dt = DateTime->now();
          my $adopt = DateTime->from_epoch(epoch => $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{born});
          my $duration = $dt->subtract_datetime($adopt);
          my @dur = $duration->in_units('days','hours','minutes');
          my $lifetime = &{$utility{'Fancify_main'}}(">>$dur[0] days, >>$dur[1] hours, and >>$dur[2] minutes.");
          my $adoption = &{$utility{'Fancify_main'}}(">>".$adopt->month_name()." >>".$adopt->day().", >>".$adopt->year()." at >>".$adopt->hour_12().":>>".$adopt->minute().$adopt->am_or_pm()." GMT");
          my $assasination = &{$utility{'Fancify_main'}}(">>$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{survived} attacks.");
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Rock_getWisdom'}}($_[0],$_[2]{where},">>rock was adopted on $adoption and has been with $_[2]{where} for $lifetime >>genderselfcap has survived $assasination"));
        }
      }
    },
    '^TopRocks$' => {
      'tags' => ['innovative','game'],
      'description' => "Shows top rocks.",
      'cooldown' => 5,
      'code' => sub { &{$utility{'Rock_topRocks'}}($_[0],$_[1]{irc},$_[2]{where}); }
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
            &{$utility{'Rock_protect'}}($_[0],$_[2]{where},-300);
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
        }
      }
    },
    '^Rock help$' => { 'tags' => ['innovative','game'], 'description' => "Shows rock commands.", 'cooldown' => 5, 
    code => sub { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"What can you do with your rock? Try >>Rock >>Feed, >>Rock >>Pet, >>Rock >>Throw >>TARGET, >>Rock >>Wash, or if you're a horrible person. >>Rock >>Kill"); }},
    '^Rock pet$' => { 'tags' => ['innovative','game'], 'description' => "Pets the local rock.", 'cooldown' => 5, },
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