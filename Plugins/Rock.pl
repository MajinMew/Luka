addPlug('Rock',{
  'creator' => 'Caaz',
  'version' => '1',
  'description' => "More Games, they said.",
  'name' => 'Virtual Pet Rock',
  'dependencies' => ['Core_Utilities','Fancify','Core_Command','Caaz_Utilities'],
  'utilities' => {
    'timer' => sub {
      lkDebug("Meow");
      foreach $serverName (keys %{$lk{data}{plugin}{'Rock'}{rocks}}) {
        foreach $channel (keys %{$lk{data}{plugin}{'Rock'}{rocks}{$serverName}}) {
          my $handle = &{$utility{'Core_Utilities_getHandle'}}($serverName);
          &{$utility{'Fancify_say'}}($handle,$channel,&{$utility{'Rock_getWisdom'}}($serverName,$channel));
        }
      }
      addTimer(time+(int(rand(240)+240)),{'name' => 'rock', 'code' => $lk{plugin}{'Rock'}{utilities}{timer}});
    },
    'adopt' => sub {
      # Server, Handle, Where.
      if(!$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]}) {
        # No Rock exists, so create one.
        # number=1&gender=m&surname=&all=no&usage_eng=1&usage_jap=1
        #  &{$utility{'Caaz_Utilities_randName'}}();
        my %rock = ('born'=>time);
        if(rand > .5) {
          # Male
          $rock{gender} = "Male";
          $rock{name} = &{$utility{'Caaz_Utilities_randName'}}({'number'=>1,'gender'=>'m','all'=>'no','usage_eng'=>1,'usage_jap'=>1});
        }
        else {
          # Female
          $rock{gender} = "Female";
          $rock{name} = &{$utility{'Caaz_Utilities_randName'}}({'number'=>1,'gender'=>'f','all'=>'no','usage_eng'=>1,'usage_jap'=>1});
        }
        lkDebug("Doing it?");
        %{$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]}} = %rock;
        lkDebug("Rick?");
        &{$utility{'Fancify_say'}}($_[1],$_[2],"Congratulations, $_[2]. You've just adopted \x04$rock{name} the rock\x04. Please take care of it.");
        return 1;
      }
      else {
        # A rock exists already...
        return 0;
      }
    },
    'getWisdom' => sub {
      # Server Name, Channel.
      my @wisdom = split /\s/, $lk{data}{plugin}{'Rock'}{wisdom}[rand @{$lk{data}{plugin}{'Rock'}{wisdom}}];
      my %gender;
      if($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{gender} =~ /^Male$/) { %gender = ('self'=>'he'); }
      else { %gender = ('self'=>'she'); }
      while((join " ", @wisdom) =~ />>\w/) {
        foreach(@wisdom) {
          if(/>>rock/i) { $_ = "\x04$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[1]}{name} the rock\x04" }
          elsif(/>>gender(\w+)/){ $_ = $gender{$1}; }
          elsif(/>>name/) { $_ = &{$utility{'Caaz_Utilities_randName'}}(); }
          elsif(/>>(\w+)/) { $_ = $lk{data}{plugin}{'Rock'}{$1}[rand @{$lk{data}{plugin}{'Rock'}{$1}}]; }
        }
      }
      return join " ", @wisdom;
    }
  },
  'code' => {
    'load' => sub {
      my $caught = 0;
      foreach $time (keys %{$lk{timer}}) { foreach(@{$lk{timer}{$time}}) { $caught = 1 if(${$_}{name} =~ /^rock$/i); } }
      if(!$caught) { addTimer(time+(int(rand(120)+60)),{'name' => 'rock', 'code' => $lk{plugin}{'Rock'}{utilities}{timer}}); }
    }
  },
  'commands' => {
    '^Rock (.+?) Add (.*)$' => {
      'access' => 1,
      'code' => sub {
        my ($group, $line) = ($1,$2);
        $group =~ tr[A-Z][a-z];
        push(@{$lk{data}{plugin}{'Rock'}{$group}},$line);
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$group increased to >>".@{$lk{data}{plugin}{'Rock'}{$group}});
      }
    },
    '^Rock$' => {
      'tags' => ['innovative'],
      'description' => "Adopts a pet rock.",
      'code' => sub { 
        if(!$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}) {
          # No Rock exists
          &{$utility{'Rock_adopt'}}($_[0],$_[1]{irc},$_[2]{where});
        }
        else {
          # A rock exists already...
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"$_[2]{where}'s pet rock: \x04$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{name} the $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{gender} Rock\x04 who was born on ".localtime($lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{born}).".");
        }
      }
    },
    '^Kill Rock$' => {
      'tags' => ['4horriblepeople'],
      'description' => "Kills the local pet rock. Only terrible people do this.",
      'code' => sub { 
        if(!$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}) {
          # No Rock exists
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"There's no rock here to kill.");
        }
        else {
          # A rock exists already...
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"\x04$lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}}{name} the Rock\x04 has died.");
          delete $lk{data}{plugin}{'Rock'}{rocks}{$_[0]}{$_[2]{where}};
        }
      }
    }
  }
});