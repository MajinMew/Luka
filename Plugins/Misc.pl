addPlug("Caaz_Utilities", {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Misc utilities',
  'dependencies' => ['Core_Utilities'],
  'modules' => ['HTML::Entities', 'LWP::Simple'],
  'utilities' => {
    'randName' => sub {
      my $url = 'http://www.behindthename.com/random/random.php?';
      if($_[0]) {
        lkDebug('Using Params');
        my @params;
        foreach(keys %{$_[0]}){ push(@params,"$_=$_[0]{$_}"); }
        $url .= join '&', @params;
      }
      else { lkDebug("Using default."); $url .= 'number=1&gender=both&surname=&all=no&usage_eng=1'; }
      lkDebug($url);
      if(get($url) =~ /\<span class=\"heavyhuge\"\>(.+?)\<\/span\>/is) {
        my $capture = $1;
        my @name;
        while($capture =~ /\<a class=\"plain\".+?\>(.+?)\<\/a\>/g) { push(@name, $1); }
        return decode_entities(join " ", @name);
      }
      return 'NONAME';
    },
    'pluralize' => sub {
      # Input: Word, count.
      my $word = $_[0];
      if((!$_[1]) || ($_[1] >= 2)) {
        if($word =~ /y$/) { $word =~ s/y$/ies/; }
        elsif($word =~ /s$/) { return $word; }
        else { $word .= 's'; }
      }
      return $word;
    },
  },
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^invite$/i) {
        push(@{$lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{autojoin}}, $irc{msg}[3]);
        lkRaw($irc{irc},"JOIN $irc{msg}[3]");
        &{$utility{'Fancify_say'}}($irc{irc}, $irc{msg}[3], "[Invited by \x04$irc{msg}[0]\x04] This channel is added to >>autojoin. If you ever wish to remove me, simply kick me and I won't be coming back. To see command listing, check out >>help. Command prefix is \x04$lk{data}{prefix}\x04 Better learn regex.");
        #&{$utility{'Fancify_say'}}($irc{irc}, (split /\!|\@/, $irc{msg}[0])[0], "Memo Caaz if you want me in $irc{msg}[3].");
      }
      #Rizon:Caaz!Caaz@I.am.Caazy.you.see:KICK:#TheFusion:Caaz:God dammit
      elsif($irc{msg}[1] =~ /^kick$/i) {
        if($irc{msg}[3] =~ /^$lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{nickname}$/i) {
          @{$lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{autojoin}} = grep(!/^$irc{msg}[2]$/i, @{$lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{autojoin}});
        }
      }
    }
  }
});
addPlug("Poll", {
  'name' => "Poll",
  'dependencies' => ['Fancify'],
  'version' => 1,
  'description' => "This plugin is here so that the general users can create polls which other people can vote on. It's great for making up minds and deciding whether rwby is anime.",
  'commands' => {
    # poll open Do you think Luka 4 is awesome? Yes, No
    # return ID.
    # poll Close ID
    # poll vote ID Option
    # poll list
    '^Polls$' => {
      'cooldown' => 5,
      'description' => "Lists available open polls.",
      'code' => sub {
        my $j = 0;
        foreach(@{$_[3]{polls}}) {
          lkDebug(${$_}{creator}.' - '.${$_}{question});
          my $string = ($j+1).": [>>${$_}{creator}] \x04${$_}{question}\x04";
          my $i = 0;
          foreach $answer (@{${$_}{answers}}) {
            $string .= " [${$answer}{text} (\x04${$answer}{votes}\x04)]";
            $i++;
          }
          &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},$string);
          $j++;
        }
      }
    },
    '^Poll open (.+?\?) (.+)$' => {
      'description' => "Opens a new poll.",
      'example' => 'Poll open What pokemon do you choose? Bulbasaur, Charmander, Squirtle',
      'code' => sub {
        my %poll = ('creator' => $_[2]{nickname}, 'question' => $1, 'total' => 0);
        if(@{$_[3]{polls}} > 3) { &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"Sorry, too many polls exist!"); return 1; }
        foreach(split /, /, $2) {
          push(@{$poll{answers}}, {'text' => $_, 'votes' => 0});
        }
        push(@{$_[3]{polls}}, \%poll);
        &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"Created poll! Check the poll IDs with \x04~polls\x04 and vote with \x04~vote PollID Option");
      }
    },
    '^Poll close (\d+)$' => {
      'description' => "Closes a poll that you've created.",
      'code' => sub {
        my $poll = $1;
        $poll--;
        if($_[3]{polls}[$poll]) {
          if($_[3]{polls}[$poll]{creator} =~ /^$_[2]{nickname}$/) {
            &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"Closed poll.");#
            delete $_[3]{polls}[$poll];
            @{$_[3]}{polls} = grep(!/^$/i, @{$_[3]}{polls});
          }
        }
        else {
          &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"No poll found with ID >>$poll.");
        }
      }
    },
    '^Vote (\d+) (.+)' => {
      'description' => "Votes for an option on a poll.",
      'example' => "Vote 0 Bulbasaur",
      'code' => sub {
        my ($poll,$option) = ($1,$2);
        $poll--;
        if($_[3]{polls}[$poll]) {
          foreach(@{$_[3]{polls}[$poll]{voted}}) {
            if($_ =~ /$_[2]{host}$/) { &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"You've already voted, >>$_[2]{nickname}."); return 0; }
          }
          if($option =~ /^\d+$/i) {
            $option -= 1;
            if($_[3]{polls}[$poll]{answers}[$option]) {
              push(@{$_[3]{polls}[$poll]{voted}}, $_[2]{host});
              $_[3]{polls}[$poll]{answers}[$option]{votes}++;
              &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"Successfully voted $_[3]{polls}[$poll]{answers}[$option]{text}!");
            }
            else {
              &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"No option found with ID >>".($option+1).".");
            }
          }
          else {
            my $i = 0; my $catch = "NULL";
            foreach(@{$_[3]{polls}[$poll]{answers}}) {
              if(${$_}{text} =~ /^$option/i) {
                $catch = $i;
                last;
              }
              $i++;
            }
            if($catch !~ /NULL/) {
              push(@{$_[3]{polls}[$poll]{voted}}, $_[2]{host});
              $_[3]{polls}[$poll]{answers}[$catch]{votes}++;
              &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"Successfully voted $_[3]{polls}[$poll]{answers}[$catch]{text}!");
            }
            else {
              &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"No option found matching \x04$option\x04.");
            }
          }
        }
        else {
          &{$utility{"Fancify_say"}}($_[1]{irc},$_[2]{where},"No poll found with ID >>$poll.");
        }
      }
    },
    '^Poll clear$' => {
      'description' => "Clears all polls.",
      'access' => 3,
      'code' => sub {
        delete $_[3]{polls};
      }
    }
  }
});
## Misc Commands is here.
addPlug("Misc_Commands", {
  'creator' => 'Caaz',
  'name' => 'Misc Commands',
  'dependencies' => ['Fancify','Caaz_Utilities'],
  'modules' => ['Sys::Hostname'],
  'description' => "This is generally where I throw commands that aren't important/big enough to have their own plugin.",
  'help' => {
    'Commands' => "The commands list is over here https://dl.dropboxusercontent.com/u/9305622/Luka/Commands.html This page is updated whenever someone uses the ~commands command."
  },
  'commands' => {
    '^Topic (.*)$' => {
      'access' => 3,
      'tags' => ['utility'],
      'description' => "Sets the topic, using Luka's Fancify to pretty it up.",
      'code' => sub {
        lkRaw($_[1]{irc},"TOPIC $_[2]{where} :".&{$utility{'Fancify_main'}}($1));
      }
    },
    '^Timer (\d+) (.+)$' => {
      'tags' => ['misc','utility'],
      'description' => "Issues a timer! Available options are say and action.",
      'code' => sub {
        my ($time, $command) = ($1,$2);
        if($command =~ /^say (.+)/i) {
          addTimer(time+$time, {
          'name' => "User Timer",
          'code' => sub { 
            lkDebug($_[1]);
            my @a = @{$_[1]}; 
            lkDebug(join ", ", @a); 
            &{$utility{'Fancify_say'}}(@a); 
          },
          'args'=>[$_[1]{irc},$_[2]{where},$1]});
        }
      },
    },
    '^Say (.+)$' => {
      'tags' => ['misc'],
      'description' => "Repeats whatever you want it to say.",
      'code' => sub { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},$1); }
    },
    '^Action (.+)$' => {
      'tags' => ['misc'],
      'description' => "Repeats whatever you want it to say, in action form!",
      'code' => sub { &{$utility{'Fancify_action'}}($_[1]{irc},$_[2]{where},$1); }
    },
    '^RandName$' => {
      'tags' => ['misc','utility'],
      'description' => "Gets a random name.",
      'code' => sub { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'Caaz_Utilities_randName'}}()); }
    },
    '^Piglatin (.+)$' => {
      'tags' => ['misc'],
      'description' => "Translates text into piglatin.",
      'code' => sub {
        my $pl = $1;
        $pl =~ s/\b(qu|[cgpstw]h|[^\W0-9_aeiou])?([a-z]+)/$1?"$2$1ay":"$2way"/ieg;
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},$pl);
      }
    },
    '^Meta$' => {
      'tags' => ['utility'],
      'description' => "Gets various information about this bot. Caaz's favorite command.",
      'code' => sub {
        my @files = (<./Plugins/*.pl>,$0);
        my %count = ('lines'=>0,'comments'=>0);
        foreach(@files) {
          open NEW, "<".$_;
          my @lines = <NEW>;
          $count{lines} += @lines+0;
          foreach(@lines) { if($_ =~ /\#/) {$count{comments}++;} }
          close NEW;
        }
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"[\x04$lk{version}\x04] (".hostname()." >>$lk{os}) >>$count{lines} lines, >>$count{comments} comments, >>".(keys %{$lk{plugin}})." plugins loaded, >>".@files." files.");
      }
    }
  }
});