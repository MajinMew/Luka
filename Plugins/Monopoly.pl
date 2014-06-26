addPlug("Monopoly", {
  'creator' => 'Caaz',
  'version' => '1',
  'description' => "They said a monopoly game on IRC was impossible. I told them REPOD SAID OTHERWISE.",
  'name' => 'Monopoly',
  'dependencies' => ['Core_Utilities','Fancify'],
  'utilities' => {
    'removeAll' => sub {
      delete $lk{data}{plugin}{'Monopoly'}{games};
      return 1;
    },
    'existsGame' => sub {
      # Input: Server Name, Channel, Type.
      # Types! 
      # 0: No actual messages.
      # 1: Error Message if game doesn't exist.
      # 2: Error Message if game exists.
      # Output: True if game exists.
      if($_[2]) { 
        my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
        if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}) {
          &{$utility{'Fancify_say'}}($handle,$_[1],"A Monopoly game already exists in this channel.") if($_[2] == 2);
        }
        else {
          &{$utility{'Fancify_say'}}($handle,$_[1],"No Monopoly game exists in this channel.") if($_[2] == 1);
        }
      }
      if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}) { return 1; }
      else { return 0; }
    },
    'newGame' => sub {
      # Input: Server Name, Channel, %{params}
      # Output: True if game is created.
      # Check if game exists.
      if(!&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],2)) {
        my %game = ('turn' => -1,'jackpot' => 100,'state'=>'roster');
        #my %params = %{$_[2]};
        #foreach(['theme',0]){ $game{${$_}[0]} = $params{${$_}[0]}; $game{${$_}[0]} = ${$_}[1] if(!$game{${$_}[0]}) }
        @{$game{board}} = ({
          'name'=>"Go",
          'type'=>'go',
        },{
          name=>'Mediterranean Avenue',
          price=>60,
          rent=>[2,10,30,90,160,250],
          buildingCost=>50,
          color=>'06',
          group=>1,
          type=>'property'
        },{
          'name'=>"Community Chest",
          'type'=>'cchest',
        },{
          name=>'Baltic Avenue',
          price=>60,
          rent=>[4,20,60,180,320,450],
          buildingCost=>50,
          color=>'06',
          group=>1,
          type=>'property'
        },{
          name=>'Income Tax',
          type=>'tax'
        },{
          name=>'Reading Railroad',
          price=>200,
          type=>'railroad'
        },{
          name=>'Oriental Avenue',
          price=>100,
          rent=>[6,30,90,270,400,550],
          buildingCost=>50,
          color=>'11',
          group=>2,
          type=>'property'
        },{
          'name'=>"Chance",
          'type'=>'chance',
        },{
          name=>'Vermont Avenue',
          price=>100,
          rent=>[6,30,90,270,400,550],
          buildingCost=>50,
          color=>'11',
          group=>2,
          type=>'property'
        },{
          name=>'Conneticut Avenue',
          price=>120,
          rent=>[8,40,100,300,450,600],
          buildingCost=>50,
          color=>'11',
          group=>2,
          type=>'property'
        },{
          name=>'Jail',
          type=>'jail'
        },{
          name=>'St.Charles Place',
          price=>140,
          rent=>[10,50,150,450,625,750],
          buildingCost=>100,
          color=>'13',
          group=>3,
          type=>'property'
        },{
          name=>'Electric Company',
          price=>150,
          type=>'utility'
        },{
          name=>'States Avenue',
          price=>140,
          rent=>[10,50,150,450,625,750],
          buildingCost=>100,
          color=>'13',
          group=>3,
          type=>'property'
        },{
          name=>'Virginia Avenue',
          price=>160,
          rent=>[12,60,180,500,700,900],
          buildingCost=>100,
          color=>'13',
          group=>3,
          type=>'property'
        },{
          name=>'Pennsylvania Railroad',
          price=>200,
          type=>'railroad'
        },{
          name=>'St.James Place',
          price=>180,
          rent=>[14,70,200,550,750,950],
          buildingCost=>100,
          color=>'07',
          group=>4,
          type=>'property'
        },{
          'name'=>"Community Chest",
          'type'=>'cchest',
        },{
          name=>'Tennessee Avenue',
          price=>180,
          rent=>[14,70,200,550,750,950],
          buildingCost=>100,
          color=>'07',
          group=>4,
          type=>'property'
        },{
          name=>'New York Avenue',
          price=>200,
          rent=>[16,80,220,600,800,1000],
          buildingCost=>100,
          color=>'07',
          group=>4,
          type=>'property'
        },{
          name=>'Free Parking',
          type=>'free'
        },{
          name=>'Kentucky Avenue',
          price=>220,
          rent=>[18,90,250,700,875,1050],
          buildingCost=>150,
          color=>'04',
          group=>5,
          type=>'property'
        },{
          'name'=>"Chance",
          'type'=>'chance',
        },{
          name=>'Indiana Avenue',
          price=>220,
          rent=>[18,90,250,700,875,1050],
          buildingCost=>150,
          color=>'04',
          group=>5,
          type=>'property'
        },{
          name=>'Illinois Avenue',
          price=>240,
          rent=>[20,100,300,750,925,1100],
          buildingCost=>150,
          color=>'04',
          group=>5,
          type=>'property'
        },{
          name=>'B&O Railroad',
          price=>200,
          type=>'railroad'
        },{
          name=>'Atlantic Avenue',
          price=>260,
          rent=>[22,110,330,800,975,1150],
          buildingCost=>150,
          color=>'08',
          group=>6,
          type=>'property'
        },{
          name=>'Ventor Avenue',
          price=>260,
          rent=>[22,110,330,800,975,1150],
          buildingCost=>150,
          color=>'08',
          group=>6,
          type=>'property'
        },{
          name=>'Water Works',
          price=>150,
          type=>'utility'
        },{
          name=>'Marvin Gardens',
          price=>280,
          rent=>[24,120,360,850,1025,1200],
          buildingCost=>150,
          color=>'08',
          group=>6,
          type=>'property'
        },{
          name=>'Go to Jail',
          type=>'go2jail'
        },{
          name=>'Pacific Avenue',
          price=>300,
          rent=>[26,130,290,900,1100,1275],
          buildingCost=>200,
          color=>'03',
          group=>7,
          type=>'property'
        },{
          name=>'North Carolina Avenue',
          price=>300,
          rent=>[26,130,290,900,1100,1275],
          buildingCost=>200,
          color=>'03',
          group=>7,
          type=>'property'
        },{
          'name'=>"Community Chest",
          'type'=>'cchest',
        },{
          name=>'Pennsylvania Avenue',
          price=>320,
          rent=>[28,150,450,1000,1200,1400],
          buildingCost=>200,
          color=>'03',
          group=>7,
          type=>'property'
        },{
          name=>'Short Line',
          price=>200,
          type=>'railroad'
        },{
          'name'=>"Chance",
          'type'=>'chance',
        },{
          name=>'Park Place',
          price=>350,
          rent=>[35,175,500,1100,1300,1500],
          buildingCost=>200,
          color=>'02',
          group=>8,
          type=>'property'
        },{
          'name'=>"Luxury Tax",
          'type'=>'luxtax',
        },{
          name=>'Boardwalk',
          price=>400,
          rent=>[50,100,200,600,1400,1700,2000],
          buildingCost=>200,
          color=>'02',
          group=>8,
          type=>'property'
        });
        #%{$game{cards}} = %{$lk{tmp}{plugin}{'Monopoly'}{themes}[$game{theme}]{cards}};
        %{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}} = %game;
        my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
        &{$utility{'Fancify_say'}}($handle,$_[1],"Game created.");
        
      }
    },
    'isPlayer' => sub {
      # Input: Server Name, Channel, Nickname
      # Output: True if player exists.
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1])) {
        foreach(keys %{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}}) {
          if($_ =~ /^$_[2]$/) {
            return 1;
          }
        }
      }
      return 0;
    },
    'isTurn' => sub {
      # Input: Server Name, Channel, Nickname
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1])) {
        my $turn = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn};
        my $curPlayer = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turnOrder}[$turn];
        lkDebug("Comparing $curPlayer to $_[2]");
        if($curPlayer =~ /^$_[2]$/i) {
          return 1;
        }
      }
      return 0;
    },
    'addAI' => sub {
      # Input: Server Name, Channel
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        my $name = &{$utility{'Caaz_Utilities_randName'}}();
        while(&{$utility{'Monopoly_isPlayer'}}($_[0],$_[1],$name)) { $name = &{$utility{'Caaz_Utilities_randName'}}(); }
        &{$utility{'Monopoly_addPlayer'}}($_[0],$_[1],$name,1);
        return 1;
      }
      return 0;
    },
    'addPlayer' => sub {
      # Input: Server Name, Channel, Nickname, AI?
      # Output: True if added.
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
        if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{state} =~ /^roster$/) {
          if(!&{$utility{'Monopoly_isPlayer'}}($_[0],$_[1],$_[2])) {
            if($_[3]) {
              %{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$_[2]}} = ('money'=>2000,'position'=>0,'AI'=>1);
              &{$utility{'Fancify_say'}}($handle,$_[1],"Added \x04$_[2]\x04 to the game! (AI)");
            }
            else {
              %{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$_[2]}} = ('money'=>2000,'position'=>0);
              &{$utility{'Fancify_say'}}($handle,$_[1],"Added \x04$_[2]\x04 to the game!");
            }
            return 1;
          }
          else {
            &{$utility{'Fancify_say'}}($handle,$_[1],"You've already joined the game, \x04$_[2]\x04.");
          }
        }
        else {
            &{$utility{'Fancify_say'}}($handle,$_[1],"You can't join the game right now, \x04$_[2]\x04.");
        }
      }
      return 0;
    },
    'startGame' => sub {
      # Input: Server Name, Channel
      # Output: True if started.
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
        if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{state} =~ /^roster$/) {
          my @players = keys %{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}};
          if(@players > 1) {
            &{$utility{'Core_Utilities_shuffle'}}(\@players);
            @{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turnOrder}} = @players;
            &{$utility{'Fancify_say'}}($handle,$_[1],"Starting the game. The turn order is as follows: \x04".(join "\x04, \x04", @players));
            ## Do next Turn
            &{$utility{'Monopoly_nextTurn'}}(@_);
            return 1;
          }
          else {
            &{$utility{'Fancify_say'}}($handle,$_[1],"There aren't enough players to start the game!");
            return 0;
          }
        }
      }
      return 0;
    },
    'nextTurn' => sub {
      # Input: Server Name, Channel.
      # Output: True if succeeded.
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
        $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn}++;
        if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn} >= @{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turnOrder}}) {
          $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn} = 0;
        }
        my $player = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turnOrder}[$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn}];
        &{$utility{'Fancify_say'}}($handle,$_[1],"[\x04$player\x04's turn] [\x04\$".$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$player}{money}."\x04] Commands: >>Roll");
        &{$utility{'Monopoly_showBoard'}}(@_);
        $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{state} = 'player_wait';
        if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$player}{AI}) {
          addTimer(time+int(rand(2)+4), { 'name' => "Monopoly AI Timer", 'code' => $utility{'Monopoly_AI'}, 'args'=>[$_[0],$_[1]]});
        }
        return 1;
      }
      return 0;
    },
    'AI' => sub {
      my @arg = @{$_[1]};
      # Input: Server Name, Channel.
      if(&{$utility{'Monopoly_existsGame'}}($arg[0],$arg[1])) {
        my %game = %{$lk{data}{plugin}{'Monopoly'}{games}{$arg[0]}{$arg[1]}};
        my $turn = $game{turn};
        my $curPlayer = $game{turnOrder}[$turn];
        if($game{state} =~ /player_wait/) {
          &{$utility{'Monopoly_playerRoll'}}($arg[0],$arg[1],$curPlayer);
        }
        elsif($game{state} =~ /player_land/) {
          my %tile = &{$utility{'Monopoly_getTile'}}($arg[0],$arg[1],$lk{data}{plugin}{'Monopoly'}{games}{$arg[0]}{$arg[1]}{players}{$curPlayer}{position},0,1);
          if($lk{data}{plugin}{'Monopoly'}{games}{$arg[0]}{$arg[1]}{players}{$curPlayer}{money} >= $tile{price}){
            # Has enough money.
            if($lk{data}{plugin}{'Monopoly'}{games}{$arg[0]}{$arg[1]}{players}{$curPlayer}{money} >= 200) {
              &{$utility{'Monopoly_playerBuy'}}($arg[0],$arg[1],$curPlayer);
            }
          }
          &{$utility{'Monopoly_playerPass'}}($arg[0],$arg[1],$curPlayer);
        }
      }
    },
    'getTile' => sub {
      # Input: Server Name, Channel, Position, Shortened?, Info instead?
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        my $position = $_[2];
        while($position > (@{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{board}}-1)) {
          $position -= @{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{board}};
        }
        my %tile = %{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{board}[$position]};
        if($_[3]) {
          $tile{name} =~ s/Avenue/Ave/g;
          $tile{name} =~ s/Street/St/g;
          $tile{name} =~ s/Railroad/RR/g;
          $tile{name} =~ s/Community/Com/g;
          $tile{name} =~ s/^Free //g;
          $tile{name} = substr($tile{name},0,10);
          $tile{name} =~ s/\s.{1,2}$//g;
          $tile{name} =~ s/\s$//g;
        }
        if(!$tile{color}) { $tile{color} = 14; }
        if(!$_[4]) {
          my $turn = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn};
          my $curPlayer = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turnOrder}[$turn];
          if(($tile{owner}) && ($tile{owner} !~ /^$curPlayer$/)) {
            return "\x04\cC04[\cC$tile{color}$tile{name}\cC04]\x04";
          }
          elsif(($tile{owner}) && ($tile{owner} =~ /^$curPlayer$/)) {
            return "\x04\cC09[\cC$tile{color}$tile{name}\cC09]\x04";
          }
          else {
            return "[\x04\cC$tile{color}$tile{name}\x04]";
          }
        }
        else {
          return %tile;
        }
      }
      return 0;
    },
    'showBoard' => sub {
      # Input: Server Name, Channel
      # Output: True if succeeded.
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
        my %player = %{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turnOrder}[$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn}]}};
        
        my @board;
        foreach(($player{position}+1)..($player{position}+12)) {
          push(@board, &{$utility{'Monopoly_getTile'}}($_[0],$_[1],$_,1));
        }
        &{$utility{'Fancify_say'}}($handle,$_[1],"[You] ".(join " ", @board));
      }
    },
    'roll' => sub {
      my $roll = 0;
      foreach(0..1) { $roll += int(rand(6))+1; }
      return $roll;
    },
    'getSpaceCount' => sub {
      # Input: Server Name, Channel, Type, Name,
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        my $turn = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn};
        my $curPlayer = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turnOrder}[$turn];
        my %tile = &{$utility{'Monopoly_getTile'}}($_[0],$_[1],$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{position},0,1);
        my $position = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{position};
        my $steps = 0;
        while(1) {
          if($tile{type} =~ /$_[2]/i) {
            if($tile{name} =~ /$_[3]/i) {
              return $steps;
            }
          }
          $steps++;
          %tile = &{$utility{'Monopoly_getTile'}}($_[0],$_[1],$position+$steps,0,1);
        }
      }
    },
    'move' => sub {
      # Input: Server Name, Channel, Count, DisableGo?, DisableLanding?
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
        my $roll = $_[2];
        my $turn = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turn};
        my $curPlayer = $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{turnOrder}[$turn];
        foreach(1..$roll) {
          $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{position}++;
          if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{position} >= (@{$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{board}}-1)) {
            $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{position} = 0;
            $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{money} += 200;
            &{$utility{'Fancify_say'}}($handle,$_[1],"\x04$curPlayer\x04 passed go and collected \x04\$200\x04!"); ## Moneyify?
          }
        }
        &{$utility{'Fancify_say'}}($handle,$_[1],"\x04$curPlayer\x04 rolled >>$roll and landed on ".(&{$utility{'Monopoly_getTile'}}($_[0],$_[1],$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{position})));
        # Okay, you landed... Figure out what to do.
        
        ## All ze landing code
        
        ## Seriously this is an important part of code don't lose it.
        my %tile = &{$utility{'Monopoly_getTile'}}($_[0],$_[1],$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{position},0,1);
        if($tile{type} =~ /property|railroad|utility/) {
          if(($tile{owner}) && ($tile{owner} !~ /^$curPlayer$/)) {
            # Someone owns it other than you
            &{$utility{'Fancify_say'}}($handle,$_[1],"Paid out rent to $tile{owner}"); # Make this a subroutine.
            &{$utility{'Monopoly_nextTurn'}}($_[0],$_[1]);
          }
          elsif(!$tile{owner}) {
            # No one owns it.
            $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{state} = 'player_land';
            &{$utility{'Fancify_say'}}($handle,$_[1],"No one owns this tile. Would you like to buy it for \x04\$$tile{price}\x04? >>Buy or >>Pass");
            if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$curPlayer}{AI}) {
              addTimer(time+int(rand(2)+4), { 'name' => "Monopoly AI Timer", 'code' => $utility{'Monopoly_AI'}, 'args'=>[$_[0],$_[1]]});
            }
          }
          else {
            # You own it.
            &{$utility{'Monopoly_nextTurn'}}($_[0],$_[1]);
          }
        }
        else {
          &{$utility{'Fancify_say'}}($handle,$_[1],"No code defined for $tile{type}, so we're just gonna end the turn.");
          &{$utility{'Monopoly_nextTurn'}}($_[0],$_[1]);
        }
      }
    },
    'playerRoll' => sub {
      # Input: Server Name, Channel, Nickname
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{state} =~ /^player_wait$/) {
          if(&{$utility{'Monopoly_isTurn'}}($_[0],$_[1],$_[2])) {
            &{$utility{'Monopoly_move'}}($_[0],$_[1],&{$utility{'Monopoly_roll'}}());
          }
        }
      }
    },
    'playerPass' => sub {
      # Input: Server Name, Channel, Nickname
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{state} =~ /^player_land$/) {
          if(&{$utility{'Monopoly_isTurn'}}($_[0],$_[1],$_[2])) {
            &{$utility{'Monopoly_nextTurn'}}($_[0],$_[1]);
          }
        }
      }
    },
    'playerBuy' => sub {
      # Input: Server Name, Channel, Nickname
      if(&{$utility{'Monopoly_existsGame'}}($_[0],$_[1],1)) {
        if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{state} =~ /^player_land$/) {
          if(&{$utility{'Monopoly_isTurn'}}($_[0],$_[1],$_[2])) {
            # Check if money is enough
            my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
            my %tile = &{$utility{'Monopoly_getTile'}}($_[0],$_[1],$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$_[2]}{position},0,1);
            if($lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$_[2]}{money} >= $tile{price}){
              # Has enough money.
              $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$_[2]}{money} -= $tile{price};
              $lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{board}[$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$_[2]}{position}]{owner} = $_[2];
              &{$utility{'Fancify_say'}}($handle,$_[1],"\x04$_[2]\x04 Bought ".(&{$utility{'Monopoly_getTile'}}($_[0],$_[1],$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$_[2]}{position})));
            }
            else {
              &{$utility{'Fancify_say'}}($handle,$_[1],"You don't have enough money to buy ".(&{$utility{'Monopoly_getTile'}}($_[0],$_[1],$lk{data}{plugin}{'Monopoly'}{games}{$_[0]}{$_[1]}{players}{$_[2]}{position})));
            }
            &{$utility{'Monopoly_nextTurn'}}($_[0],$_[1]);
          }
        }
      }
    },
  },
  'code' => {
    'load' => sub {
      @{$lk{tmp}{plugin}{'Monopoly'}{cards}} = ({
        'cchest' => [],
        'chance' => [{
          name=>'Advance to Go',
          code=>sub {
            # MoveTo 0
          }
        },{
          name=>'Advance to Illinois Avenue - If you pass Go, collect $200.',
          code=>sub {
            # MoveTo, Property, Illinois Avenue,
          }
        },{
          name=>'Advance to St. Charles Place. - If you pass Go, collect $200.',
          code=>sub {
            # MoveTo, Property, St.Charles Place,
          }
        },{
          name=>"Advance to nearest Utility. If unowned, you may buy it from the bank. If owned, throw dice and pay owner a total of ten times the amount thrown.",
          oode=>sub {
            # MoveTo, Utility, . No Landing
          }
        },{
          name=>"Advance to the nearest Railroad and pay owner twice the rental to which he/she is otherwise entitled. If railroad is unowned, you may buy it from the bank.",
          code=>sub {
            # MoveTo, Railroad, . No Landing
          }
        },{
          name=>"Bank pays you divident of \$50.",
          code=>sub {
            # gain 50
          }
        },{
          name=>"Get out of Jail free.",
          code=>sub {
            # GOOJ
          }
        },{
          name=>"Go back 3 spaces.",
          code=>sub {
            # Back 3
          }
        },{
          name=>"Go directly to Jail. Do not pass Go, do not collect \$200.",
          code=>sub {
            # MoveTo, Jail, no Go, NoLand, Jail.
          }
        },{
          name=>"Make general repairs on all your property - For each house pay \$25 - For each hotel, \$100.",
          code=>sub{
            # For each board, check if owned, check if has buildings, check if hotels,
          }
        },{
          name=>"Pay poor tax of \$15",
          code=>sub {
            # Take 15
          }
        },{
          name=>"Take a trip to Reading Railroad. If you pass Go, collect \$200.",
          code=>sub {
            # MoveTo, railroad, Reading Railroad
          }
        },{
          name=>"Take a walk on the Boardwalk - Advance to the Boardwalk.",
          code=>sub {
            # MoveTo, Property, 
          }
        },{
          name=>"You have been elected Chairmen of the Board - Pay each player \$50",
          code=>sub {
            # Foreach player, pay them 50
          }
        },{
          name=>"Your building loan matures - Collect \$150",
          code=>sub {
            # get 150
          }
        },{
          name=>"You have won a crossword competition - Collect \$100",
          code=>sub {
            # get 100
          }
        }],
      });
    },
  },
  'commands' => {
    '^Monopoly$' => {
      'tags' => ['wip'],
      'description' => "Starts a game of monopoly.",
      'code' => sub {
        &{$utility{'Monopoly_newGame'}}($_[0],$_[2]{where});
      }
    },
    '^Monopoly Start$' => {
      'tags' => ['wip'],
      'description' => "Actually begins the game.",
      'code' => sub {
        &{$utility{'Monopoly_startGame'}}($_[0],$_[2]{where});
      }
    },
    '^Monopoly Clear$' => {
      'tags' => ['wip'],
      'description' => "Clears all games of monopoly.",
      'access' => 3,
      'code' => sub {
        &{$utility{'Monopoly_removeAll'}};
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Removed all monopolies");
      }
    },
    '^Monopoly Join$' => {
      'tags' => ['wip'],
      'description' => "Joins an existing game of monopoly.",
      'code' => sub {
        &{$utility{'Monopoly_addPlayer'}}($_[0],$_[2]{where},$_[2]{nickname});
      }
    },
    '^Monopoly AI$' => {
      'tags' => ['wip'],
      'description' => "Adds an AI player to the monopoly game.",
      'code' => sub {
        &{$utility{'Monopoly_addAI'}}($_[0],$_[2]{where});
      }
    },
    '^Roll$' => {
      'tags' => ['wip'],
      'description' => "Rolls the dice.",
      'code' => sub {
        &{$utility{'Monopoly_playerRoll'}}($_[0],$_[2]{where},$_[2]{nickname});
      }
    },
    '^Buy$' => {
      'tags' => ['wip'],
      'description' => "Buys whatever property you've landed on.",
      'code' => sub {
        &{$utility{'Monopoly_playerBuy'}}($_[0],$_[2]{where},$_[2]{nickname});
      }
    },
    '^Pass$' => {
      'tags' => ['wip'],
      'description' => "Passes on buying a property.",
      'code' => sub {
        &{$utility{'Monopoly_playerPass'}}($_[0],$_[2]{where},$_[2]{nickname});
      }
    },
  },
});