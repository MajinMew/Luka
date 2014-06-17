addPlug("Colorblind", {
  'creator' => 'Caaz',
  'version' => '2',
  'name' => 'Colorblind',
  'description' => "A classic luka game that will never not be autoplayed by Reaper. The rules are simple, you name the color of a word, or the word itself! Depending on what Luka tells you. Super simple.",
  'dependencies' => ['Core_Command','Fancify'],
  'utilities' => {
    'newRound' => sub {
      # input: Network handle, where, data
      my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($_[0])}]{name};
      my @numbers = (4,7,8,9,11,12,6,13,0,14);
      my @names   = ("Red","Orange","Yellow","Green","Cyan","Blue","Purple","Pink","Rainbow","Gray");
      my $answerindex = int(rand(@names));
      $_[2]{session}{$network}{$_[1]}{answer} = $names[$answerindex];
      if(rand > .5) {
        my @word = split //, $names[rand(@names)];
        if($answerindex == 8) { my $i = 0; foreach(@word) { $_ = "\003$numbers[$i]$_"; $i++; if($i >= 9) { $i = 0; } } }
        my $text = "\003$numbers[$answerindex]".(join "", @word);
        return "Name this color! $text";
      }
      else {
        my @word = split //, $_[2]{session}{$network}{$_[1]}{answer};
        my $color = $numbers[rand(@numbers)];
        if($color == 8) { my $i = 0; foreach(@word) { $_ = "\003$numbers[$i]$_"; $i++; if($i >= 9) { $i = 0; } } }
        my $text = "\003$numbers[$color]".(join "", @word);
        return "Name this word! $text";
      };
    }
  },
  'commands' => {
    '^Colorblind( \d+)?$' => {
      'description' => "This starts up the Colorblind game, with a default of 10 rounds. You can have up to 50 rounds or as few as 1.",
      'example' => "Caaz: ~colorblind 5\nLuka: Starting 5 of Colorblind! Name this color! Red\nCaaz: cyan\n...",
      'tags' => ['game'],
      'code' => sub { 
        my $rounds = $1;
        if($lk{data}{'Colorblind'}{session}{$_[0]}{$_[2]{where}}) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Session already exists here!"); return 0; }
        if($rounds) {
          $rounds =~ s/^\s//g;
          if($rounds < 1) { $rounds = 1; } if($rounds > 50) { $rounds = 50; }
          $lk{data}{'Colorblind'}{session}{$_[0]}{$_[2]{where}}{rounds} = $rounds;
        }
        else { $lk{data}{'Colorblind'}{session}{$_[0]}{$_[2]{where}}{rounds} = 10; }
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Starting >>$lk{data}{'Colorblind'}{session}{$_[0]}{$_[2]{where}}{rounds} of Colorblind! ".&{$utility{'Colorblind_newRound'}}($_[1]{irc},$_[2]{where},$lk{data}{'Colorblind'}));
      }
    }
  },
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{name};
        if(($lk{data}{'Colorblind'}{session}{$network}{$parsed{where}}) && ($parsed{msg} =~ /^$lk{data}{'Colorblind'}{session}{$network}{$parsed{where}}{answer}$/i)) {
          $lk{data}{'Colorblind'}{session}{$network}{$parsed{where}}{rounds}--;
          if($lk{data}{'Colorblind'}{session}{$network}{$parsed{where}}{rounds} >= 1) { 
            &{$utility{'Fancify_say'}}($irc{irc},$parsed{where},"\x04$parsed{nickname} got it!\x04 ".&{$utility{'Colorblind_newRound'}}($irc{irc},$parsed{where},$lk{data}{'Colorblind'}));
          }
          else {
            delete $lk{data}{'Colorblind'}{session}{$network}{$parsed{where}};
            &{$utility{'Fancify_say'}}($irc{irc},$parsed{where},"\x04$parsed{nickname} got it!\x04 Game over!");
          }
        }
      }
    }
  }
});