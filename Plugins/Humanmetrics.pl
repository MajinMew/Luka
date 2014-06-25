addPlug("Human_Metrics", {
  'creator' => 'Caaz',
  'version' => '1',
  'description' => "This plugin provides access to the personality type test at http://www.humanmetrics.com/cgi-win/jtypes2.asp via IRC!",
  'name' => 'Human Metrics Myers Briggs Personality Test',
  'dependencies' => ['Core_Utilities','Fancify'],
  'modules' => ['LWP::Simple'],
  'utilities' => {
    'getTest' => sub {
      # True if success.
      delete $lk{data}{plugin}{'Human_Metrics'}{questions};
      my $content = get('http://www.humanmetrics.com/cgi-win/jtypes2.asp');
      #lkDebug($content);
      chomp($content);
      while ($content =~ /\<li\>(.+?)\<input name\=\"(\d+?)\"/igs) {
        my ($question,$id) = ($1,$2);
        $question =~ s/\s{2,}/ /g;
        $question =~ s/\<br \/\>|\s+$//g;
        $lk{data}{plugin}{'Human_Metrics'}{questions}{$id} = $question;
        #lkDebug("Got $question at $id");
      }
      return 1;
    },
    'post' => sub {
      # Input: Handle, Where, Nickname
      # Output: True if success.
    },
    'existsSession' => sub {
      # Input: Nickname
      # Output: 1 if yes or no, 2 if age, 3, if gender, 0 if not.
    },
    'createSession' => sub {
      # Input: Handle, Where, Nickname
      # Output: True if success.
      my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($_[0])}]{name};
      my %session;
      @{$session{questions}} = keys %{$lk{data}{plugin}{'Human_Metrics'}{questions}};
      &{$utility{'Core_Utilities_shuffle'}} = $session{questions};
      $session{place} = -1;
      %{$lk{data}{plugin}{'Human_Metrics'}{$network}{$_[2]}} = %session;
      &{$utility{'Human_Metrics_nextQuestion'}}(@_);
      &{$utility{'Fancify_say'}}($_[0],$_[1],"Session created. \x04Don't change your nick\x04. Answer the following statements with a >>yes or >>no. Make your choice based on your most typical response or feeling in the given situation. \x04This is best used in PM/Notice, where the command prefix is optional. If using this test in a channel, your answer must contain the command prefix.");
      return 1;
      
    },
    'nextQuestion' => sub {
      # Input: Handle, Where, Nickname
      # Output: True if success.
      $lk{data}{plugin}{'Human_Metrics'}{$network}{$_[2]}{place}++;
      &{$utility{'Fancify_say'}}($_[0],$_[1],'>>'.($lk{data}{plugin}{'Human_Metrics'}{$network}{$_[2]}{place} + 1).': '.$lk{data}{plugin}{'Human_Metrics'}{question}{$lk{data}{plugin}{'Human_Metrics'}{$network}{$_[2]}{questions}{$lk{data}{plugin}{'Human_Metrics'}{$network}{$_[2]}{place}}});
    },
  },
  'commands' => {
    '^Typology$' => {
      'description' => "This creates a session for the Jung Typology Test. Best used in PM",
      'tags' => ['wip'],
      'code' => sub {
        &{$utility{'Human_Metrics_createSession'}}($_[1]{irc},$_[2]{where},$_[2]{nickname});
      }
    },
    '^yes$' => {
      'code' => sub {
        if(&{$utility{'Human_Metrics_existsSession'}}($_[2]{nickname})) {
          &{$utility{'Human_Metrics_nextQuestion'}}($_[1]{irc},$_[2]{where},$_[2]{nickname});
        }
      }
    },
    '^no$' => {
    },
    '^(\d+)$' => {
    }
  }
});