#!/usr/bin/perl
# Luka's Birthday: Oct 14 15:42:23 2009 
# If there's actual programmers looking at this, forgive me, I've only been working on this for five years. I have much to learn ;~;
# Mindmap is over here -> https://coggle.it/diagram/538ec42bbea51f8044000010/f349c7e109341279d968f2efd62a4ff923f30bc5005029330309cc8709631a20
use warnings;
use Cwd 'abs_path'; # Used for more efficient chdir! Less Errors!
use IO::Select; # Used for handling connections!
use IO::Socket; # Used for connecting!
use utf8; # Used for fancy stuff, generally here to be safe.
use JSON; # Used for data saving! Because YAML is for losers.
$lk{version} = 'Luka 4.0';
$lk{select} = IO::Select->new();
($lk{directory} = abs_path($0)) =~ s/([\\\/])[^\\\/]+?\.pl$/$1/;
lkDebug($lk{directory});
chdir($lk{directory}) or warn "Couldn't chdir to $lk{directory}.";
eval("use Android"); if($@){ $lk{os} = $^O; } else { $lk{os} = "android"; eval('$lk{droid} = Android->new();'); }
if(!lkLoad()) {
  lkDebug("You don't have any save file! You must be new here! Welcome to Luka.");
  print "I'll need a prefix for this bot! This prefix is used globally for commands. it's gonna be thrown into regex matches, so keep that in mind.\n>";
  chomp($lk{data}{prefix} = <STDIN>);
  lkSave();
  lkDebug("You need to set up at least one network for Luka to connect to. You can do so by using the 'new' command. it'll walk you through the setup.");
}
lkLoadPlugins();
foreach('ABRT','QUIT','KILL','INT','ABRT','HUP') { $SIG{$_} = \&lkEnd; }


if(@ARGV) {
  # Got shell parameters.
  if($ARGV[0] =~ /^shell$/i) { lkShell(); }
  if($ARGV[0] =~ /^help$/i) { lkDebug("No help for you"); exit 1; }
  else {
    lkDebug("Unknown Parameters. Going to try connecting.");
    lkConnect();
  }
}
else {
  # No parameters! Start connecting.
  lkConnect();
}

sub lkShell {
  # Show splash screen!?
  # Set up commands.
  my @commands = (
  ['^new$', 'Creates a new connection.', sub {
    my %alias;
    foreach(['name','What do you want to call this connection? This name is used to identify it in the output.'],
    ['host','What do you want to connect to? eg. irc.rizon.net'],
    ['port','What port do you want to use? eg. 6667'],
    ['nickname','What nickname do you want to connect with? THIS!*@*'],
    ['username','What about the username/ident? *!THIS@*'],
    ['realname','What realname do you want to use? *!*@* :This?']){
      print ${$_}[1]."\n>";
      chomp($alias{${$_}[0]} = <STDIN>);
    }
    print "Do you want to use nickserv to identify with services?\n>";
    if(<STDIN> =~ /^y/i) {
      print "What's the nickserv password? Note: This is stored in plaintext. Forgive me.\n>";
      chomp($alias{nickserv} = <STDIN>);
    }
    print "Do you want to add a channel to autojoin?\n>";
    while(<STDIN> =~ /^y/i){
      print "Name a channel!\n>";
      my $aj; chomp($aj = <STDIN>);
      push(@{$alias{autojoin}}, $aj);
      print "Do you want to add another channel to autojoin?\n>";
    }
    push(@{$lk{data}{networks}}, \%alias);
    print "Finished setup, execute \"start\" to connect now or \"commands\" to view the list of available commands.\n";
    lkSave();
  }],
  ['^disable (\d+)$', 'Disables an existing connection.', sub {
    my $target = $1;
    if($lk{data}{networks}[$target]) {
      $lk{data}{networks}[$target]{disable} = 1;
      print "Disabled network $lk{data}{networks}[$target]{name}\n";
      lkSave();
    }
    else {
      print "No network with that ID. Check the list command.\n";
    }
  }],
  ['^enable (\d+)$', 'Enable an existing connection.', sub {
    my $target = $1;
    if($lk{data}{networks}[$target]) {
      delete $lk{data}{networks}[$target]{disable};
      print "Enabled network $lk{data}{networks}[$target]{name}\n";
      lkSave();
    }
    else {
      print "No network with that ID. Check the list command.\n";
    }
  }],
  ['^list$', 'Lists connections', sub {
    my $i = 0;
    foreach(@{$lk{data}{networks}}) {
      print "$i -> ${$_}{name} - ${$_}{host}:${$_}{port} as ${$_}{nickname}\n";
      $i++;
    }
  }],
  ['^exit$', 'Exits.', \&lkEnd],
  ['^start$', 'Starts connecting.', \&lkConnect],
  ['^help|commands$', 'Shows commands', sub { foreach(@commands) { lkDebug("/${$_}[0]/ -> ${$_}[1]"); } }]);
  # List available commands.
  foreach(@commands) { lkDebug("/${$_}[0]/ -> ${$_}[1]"); }
  # Start input!
  print ">"; while(<STDIN>) { chomp; my $msg = $_; foreach(@commands) { if($msg =~ /${$_}[0]/i) { &{${$_}[2]}; } } print ">"; }
}
sub lkSave {
  # Confirmed working. Probably.
  open DATA, ">./Data.txt";
  print DATA encode_json($lk{data});
  close DATA;
}
sub lkLoad {
  # Probably working.
  lkDebug("Loading Data!");
  open DATA, "<./Data.txt";
  my $json = join "", <DATA>;
  close DATA;
  eval{%{$lk{data}} = %{decode_json($json)};};
  if($@) { return 0; } 
  else { return 1; }
}
sub lkConnectTo {
  # ID
  my $thing = $lk{data}{networks}[$_[0]];
  lkDebug("Connecting to ${$thing}{name}.");
  if(${$thing}{disable}) { lkDebug("Network ${$thing}{name} is disabled. Skipping."); return 0; }
  my $connection = new IO::Socket::INET(PeerAddr => ${$thing}{host}, PeerPort => ${$thing}{port}, Proto => 'tcp');
  if($@) { lkDebug($@); return 0; }
  else {
    $lk{tmp}{connection}{fileno($connection)} = $_[0];
    $lk{tmp}{filehandles}{fileno($connection)} = $connection;
    lkRaw($connection,"NICK ${$thing}{nickname}","USER ${$thing}{username} * 0 :${$thing}{realname}");
    $lk{select}->add($connection);
    return 1;
  }
}
sub lkConnect {
  # Start connecting to all enabled servers.
  if(($lk{data}{networks}) && (@{$lk{data}{networks}})) {
    my $i = 0;
    foreach(@{$lk{data}{networks}}) {
      lkConnectTo($i);
      $i++;
    }
    while(1) {
      # Actual event loop right here
      my $currentTime = time;
      if($lk{tmp}{lastTime}) {
        if(($currentTime-$lk{tmp}{lastTime}) > 1) {
          foreach $wTime($lk{tmp}{lastTime}..$currentTime) {
            foreach(@{$lk{timer}{$wTime}}) { eval { &{${$_}{code}}($wTime,${$_}{args}); }; if($@) { lkDebug("Timer failed: ${$_}{args} - $@"); } }
            delete $lk{timer}{$wTime};
          }
        }
        else {
          foreach(@{$lk{timer}{$currentTime}}) { eval { &{${$_}{code}}($wTime,${$_}{args}); }; if($@) { lkDebug("Timer failed: ${$_}{args} - $@"); } }
          delete $lk{timer}{$currentTime};
        }
      }
      $lk{tmp}{lastTime} = $currentTime;
      @readable = $lk{select}->can_read(1);
      foreach $fh (@readable) {
        my $rawmsg = readline($fh);
        # Handle this line properly.
        if(!$rawmsg) {
          lkDebug("Null message. Assuming disconnection.");
          delete $lk{tmp}{connection}{fileno($fh)};
          delete $lk{tmp}{filehandles}{fileno($fh)};
          $lk{select}->remove($fh);
          $fh->close;
          next;
        }
        $rawmsg =~ s/\n|\r//g;
        ## Yes I'm using the same parsing as Luka 3. Shut up.
        if($rawmsg =~ /:.*?:/) { @msg = ((split /\s/, ($rawmsg =~ /:(.*?):/)[0]), ($rawmsg =~ /:.*?:(.*)/g)[0]); } 
        else { @msg = (split /:|\s/, $rawmsg); }
        if($msg[0] =~ /^$/) { my $c = -1; foreach(@msg) { $c++; next if($c == 0); $msg[($c-1)] = $msg[$c]; } pop(@msg); }
        if($msg[1] =~ /^$/) { my $c = -1; foreach(@msg) { $c++; next if(($c == 0) || ($c == 1)); $msg[($c-1)] = $msg[$c]; } pop(@msg); @msg = reverse(@msg); }
        my $ignore = 0;
        foreach(keys %{$lk{plugin}}) { 
          if($lk{plugin}{$_}{code}{pre}) { 
            if(!&{$lk{plugin}{$_}{code}{pre}}({'irc' => $fh, 'raw' => $rawmsg, 'msg', => \@msg, 'data' => $lk{data}{plugin}{$_}, 'tmp' => $lk{tmp}{plugin}{$_}})) { $ignore++; }
          } 
        }
        if($ignore) { next; }
        #lkDebug($lk{data}{networks}[$lk{tmp}{connection}{fileno($fh)}]{name}.':'.(join ":", @msg));
        if($rawmsg =~ /^PING(.+)$/i) { lkRaw($fh,"PONG$1"); lkSave(); }
        # Rizon:irc.cccp-project.net:433:*:Luka:Nickname is already in use.
        if($msg[1] =~ /^001$/) {
          # Connected. Do nickserv stuff if needed!
          lkRaw($fh, "PRIVMSG Nickserv :id ".$lk{data}{networks}[$lk{tmp}{connection}{fileno($fh)}]{nickserv}) if($lk{data}{networks}[$lk{tmp}{connection}{fileno($fh)}]{nickserv});
          # Set up autojoin!
          foreach(@{$lk{data}{networks}[$lk{tmp}{connection}{fileno($fh)}]{autojoin}}) { lkRaw($fh,"JOIN :".$_); }
        }
        # Pass things to plugins!
        foreach(keys %{$lk{plugin}}) {
          eval { &{$lk{plugin}{$_}{code}{irc}}({'irc' => $fh, 'name'=>$lk{data}{networks}[$lk{tmp}{connection}{fileno($fh)}]{name}, 'raw' => $rawmsg, 'msg', => \@msg, 'data' => $lk{data}{plugin}{$_}, 'tmp' => $lk{tmp}{plugin}{$_}}) if($lk{plugin}{$_}{code}{irc}); };
          print $@ if $@;
        }
      }
    }
  }
  else {
    # No aliases stored!
    lkDebug("No aliases. Going to (s)hell.");
    lkShell();
  }
}
sub lkRaw {
  # Handle, Text
  my $handle = shift;
  foreach(@_) {
    print $handle "$_\n";
    print "$_\n";
  }
}
sub lkDebug {
  #! Do something more with this later.
  print $_[0]."\n";
}
sub lkUnloadPlugins {
  foreach(keys %{$lk{plugin}}) {
    &{$lk{plugin}{$_}{code}{unload}}({'data' => $lk{data}{plugin}{$_}, 'tmp' => $lk{tmp}{plugin}{$_}}) if($lk{plugin}{$_}{code}{unload});
  }
  delete $lk{plugin};
  delete $lk{tmp}{lastUpdated};
}
sub lkLoadPlugins {
  # Alright guys, here's where shit gets serious.
  my @errors = ();
  if(!-e "Plugins/") { lkDebug("No plugin directory! Making one."); mkdir("Plugins"); }
  foreach(<Plugins/*.pl>) {
    # Check file timestamps, only load plugins which are new!
    if((!$lk{tmp}{lastUpdated}{$_}) || ($lk{tmp}{lastUpdated}{$_} != (stat($_))[9])) {
      $lk{tmp}{lastUpdated}{$_} = (stat($_))[9];
      lkDebug("Loading $_.");
      open NEW, "<".$_; eval(join "", <NEW>);
      if($@){ push(@errors, {plugin=>$_,message=>$@}); delete $lk{tmp}{lastUpdated}{$_}; lkDebug($@); } 
      close NEW;
    }
  }
  # Start checking dependencies
  my $modified = 1;
  while($modified) {
    # Repeat this until everything's resolved.
    $modified = 0;
    foreach $plug (keys %{$lk{plugin}}) {
      # Cross plugin dependencies
      foreach(@{$lk{plugin}{$plug}{dependencies}}) {
        if(!$lk{plugin}{$_}){
          push(@errors, {plugin=>$plug,message=>"Didn't meet plugin dependency ($_)"});
          lkDebug("Deleting plugin $lk{plugin}{$plug}{name} ($plug). Didn't meet dependency ($_)");
          delete $lk{plugin}{$plug};
          $modified = 1;
        }
      }
      # Actual module dependencies.
      foreach(@{$lk{plugin}{$plug}{modules}}) {
        eval("use $_;");
        if($@) {
          push(@errors, {plugin=>$plug,message=>"Didn't meet module dependency ($_)"});
          lkDebug("Deleting plugin $lk{plugin}{$plug}{name} ($plug). Didn't meet module dependency ($_)");
          delete $lk{plugin}{$plug};
          $modified = 1;
        }
      }
    }
  }
  # Do te load code of all the plugins!
  foreach(keys %{$lk{plugin}}) {
    &{$lk{plugin}{$_}{code}{load}}({'data' => $lk{data}{plugin}{$_}, 'tmp' => $lk{tmp}{plugin}{$_}}) if($lk{plugin}{$_}{code}{load});
  }
  return \@errors;
}
sub lkEnd {
  lkDebug("Quitting safely.");
  lkUnloadPlugins();
  lkSave();
  foreach($lk{select}->handles) {
    lkRaw($_,"QUIT :~End~");
  }
  exit;
}
sub addTimer {
  # Time, hash.
  if($_[0] > time) {
    push(@{$lk{timer}{$_[0]}}, $_[1]);
    return 1;
  }
  else {
    lkDebug("Time value must be ahead of the current time!");
    return 0;
  }
}
sub addPlug {
  # $key, %shit
  if($lk{data}{disablePlugin}{$_[0]}) {
    # Plugin is disabled, according to config!
    lkDebug("Ignoring Plugin ${$_[1]}{name} ($_[0])");
    %{$lk{plugin}{$_[0]}} = ('name' => ${$_[1]}{name});
  }
  else {
    # Plugin is probably not disabled, so try loading it!
    # Key already exists! Warn about it, but overwrite anyway.
    if($lk{plugin}{$_[0]}) { 
      &{$lk{plugin}{$_[0]}{code}{unload}}({'data' => $lk{data}{plugin}{$_[0]}, 'tmp' => $lk{tmp}{plugin}{$_[0]}}) if($lk{plugin}{$_[0]}{code}{unload}); 
      lkDebug("Overwriting Plugin ${$_[1]}{name} ($_[0])"); 
      delete $lk{plugin}{$_[0]};
      %{$lk{plugin}{$_[0]}} = ('name' => ${$_[1]}{name});
    }
    # Key doesn't exist. Must be loading the plugin for the first time!
    else { lkDebug("Loading Plugin ${$_[1]}{name} ($_[0])"); }
    %{$lk{plugin}{$_[0]}} = %{$_[1]};
    #%{$lk{data}{plugin}{$_[0]}} = ();
    #&{$lk{plugin}{$_[0]}{code}{load}}({'data' => $lk{data}{plugin}{$_[0]}, 'tmp' => $lk{tmp}{plugin}{$_[0]}}) if($lk{plugin}{$_[0]}{code}{load});
  }
}