addPlug("Foobar",{
  'creator' => 'Caaz',
  'version' => '2',
  'name' => 'Foobar Now Playing',
  'dependencies' => ['Fancify','Core_Utilities'],
  'description' => "At mostly the request of MajinMew, this plugin was created to connect to external foobar servers and get their NP information, prettify it up, spitshine the tags, and display it for the general public to see.",
  'utilities' => {
    'timer' => sub {
      # Input!
      #lkDebug("Timer works!");
      &{$utility{'Foobar_getInfo'}};
      foreach(values %{$lk{tmp}{plugin}{'Foobar'}{handles}}) {
        if(${$_}{auto}) {
          &{$utility{'Foobar_npSay'}}(${$_}{auto}[0],${$_}{auto}[1],$_,1);
        }
      }
      addTimer(time+20,{'name'=>'np','code'=>$utility{"Foobar_timer"}});
    },
    'npSay' => sub {
      # Input : IRC handle, where, NP Hash, bool
      if(!$_[2]{info}) { return 0; }
      my $percentage = int($_[2]{info}{position}/$_[2]{info}{length}*10);
      my $bar = "\x04";
      for($i=0;$i<=$percentage;$i++) { $bar .= ">"; }
      $bar .= "\x04";
      for($i=10;$i>$percentage;$i--) { $bar .= ">"; }
      if($_[3]) {
        if(($lk{tmp}{plugin}{'Foobar'}{lastNP}{$_[2]{name}}) && ($lk{tmp}{plugin}{'Foobar'}{lastNP}{$_[2]{name}} =~ /^$_[2]{info}{title}$/)) {
          lkDebug("$lk{tmp}{plugin}{'Foobar'}{lastNP}{$_[2]{name}} matched $_[2]{info}{title}");
          return 1;
        }
        else { $lk{tmp}{plugin}{'Foobar'}{lastNP}{$_[2]{name}} = $_[2]{info}{title}; }
      }
      if($_[2]{info}{title} =~ /[\(\[].+?[\]\)]/) { $_[2]{info}{title} =~ s/([\(\[].+?[\]\)])/\x04$1\x04/; }
      &{$utility{'Fancify_say'}}($_[0],$_[1],"[\x04$_[2]{name}\x04] \x04$_[2]{info}{title}\x04 by \x04$_[2]{info}{artist}\x04 [\x04$_[2]{info}{album}\x04] [$bar]");
    },
    'getInfo' => sub {
      while(1) {
        my @readable = $lk{tmp}{plugin}{'Foobar'}{select}->can_read(1);
        if(@readable) {
          foreach $handle (@readable) {
            my $raw = readline($handle);
            chomp($raw);
            if($raw =~ /^$/){
              &{$utility{'Foobar_disconnect'}}($handle);
              next;
            }
            my @np = split /\|/, $raw;
            if($np[0] =~ /111/) {
              foreach(['artist',6],['title',5],['album',7],['position',3],['length',8]) {
                $lk{tmp}{plugin}{'Foobar'}{handles}{fileno($handle)}{info}{${$_}[0]} = $np[${$_}[1]];
              }
              lkDebug($lk{tmp}{plugin}{'Foobar'}{handles}{fileno($handle)}{name}.' - '.$raw)
            }
          }
        }
        else {
          last;
        }
      }
      return 1;
    },
    'disconnect' => sub {
      # Input, filehandle!
      $lk{tmp}{plugin}{'Foobar'}{select}->remove($_[0]);
      delete $lk{tmp}{plugin}{'Foobar'}{handles}{fileno($_[0])};
      $_[0]->close;
      return 1;
    },
    'connect' => sub {
      # Input: hash!
      if($lk{tmp}{plugin}{'Foobar'}{handles}) {
        foreach(values %{$lk{tmp}{plugin}{'Foobar'}{handles}}) {
          if(${$_}{host} =~ /^$_[0]{host}$/i) {
            lkDebug("Not connecting to ${$_}{host} -- matches already connectd.");
            return 0;
          }
        }
      }
      my $connection = new IO::Socket::INET(PeerAddr => $_[0]{host}, PeerPort => $_[0]{port}, Proto => 'tcp', Timeout => 1);
      if($@) { lkDebug($@); }
      else {
        lkDebug("Connected to $_[0]{name}");
        %{$lk{tmp}{plugin}{'Foobar'}{handles}{fileno($connection)}} = ('filehandle' => $connection, 'name' => ${$_}{name}, 'host' => ${$_}{host});
        $lk{tmp}{plugin}{'Foobar'}{select}->add($connection);
      }
    },
  },
  'code' => {
    'load' => sub {
      $lk{tmp}{plugin}{'Foobar'}{select} = IO::Select->new();
      foreach (@{$lk{data}{plugin}{'Foobar'}{servers}}) { &{$lk{plugin}{'Foobar'}{utilities}{connect}}($_); }
      my $caught = 0;
      foreach $time (keys %{$lk{timer}}) { foreach(@{$lk{timer}{$time}}) { $caught = 1 if(${$_}{name} =~ /^np$/i); } }
      if(!$caught) { addTimer(time+2,{'name' => 'np', 'code' => $lk{plugin}{'Foobar'}{utilities}{timer}}); }
      #&{$utility{'Foobar_getInfo'}};
    },
    'unload' => sub {
      if($lk{tmp}{plugin}{'Foobar'}{select}) {
        my @handles = $lk{tmp}{plugin}{'Foobar'}{select}->handles();
        lkDebug(@handles." handles?");
        foreach $io (@handles) { &{$lk{plugin}{'Foobar'}{utilities}{disconnect}}($io); }
      }
    },
  },
  'commands' => {
    '^NP(\w+)?$' => {
      'tags' => ['utility','media'],
      'description' => "Ges NP info!",
      'example' => "NPCaaz\nNP",
      'code' => sub {
        my $server = $1;
        #&{$utility{'Foobar_getInfo'}};
        $server = $_[2]{username} if(!$server);
        my $caught = 0;
        foreach (@{$lk{data}{plugin}{'Foobar'}{servers}}) { if(${$_}{name} =~ /$server/) { &{$lk{plugin}{'Foobar'}{utilities}{connect}}($_); } }
        foreach(values %{$lk{tmp}{plugin}{'Foobar'}{handles}}) {
          lkDebug(${$_}{name});
          if(${$_}{name} =~ /^$server$/i) {
            $caught++;
            print {${$_}{filehandle}} "trackinfo\n";
            &{$utility{'Foobar_getInfo'}};
            &{$utility{'Foobar_npSay'}}($_[1]{irc},$_[2]{where},$_);
          }
        }
        if(!$caught) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"$server not connected"); 
        }
      }
    },
    '^NP auto (#.+?)( \w+)?$' => {
      'tags' => ['utility','media'],
      'access' => 1,
      'description' => "Sets a channel for automatic NP posting.",
      'example' => "~NP auto #TheFusion Caaz",
      'code' => sub {
        my ($channel, $server) = ($1,$2);
        #&{$utility{'Foobar_getInfo'}};
        $server = $_[2]{username} if(!$server);
        $server =~ s/^\s//g;
        my $caught = 0;
        foreach(values %{$lk{tmp}{plugin}{'Foobar'}{handles}}) {
          lkDebug(${$_}{name});
          if(${$_}{name} =~ /^$server$/i) {
            $caught = 1;
            if(${$_}{auto}) {
              delete ${$_}{auto};
              &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$server will no longer autopost.");
            }
            else {
              ${$_}{auto} = [$_[1]{irc},$channel];
              &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$server will now autopost to $channel (Temporarily, at least. This lasts until the next restart).");
            }
          }
        }
        if(!$caught) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"$server not found."); }
      }
    },
    '^NP add (.+?) (.+?)(\:\d)?$' => {
      'tags' => ['utility','media'],
      'description' => "Adds a server to NP",
      'example' => "NP add Name some.ip.address:3333",
      'access' => 1,
      'code' => sub {
        my ($name,$host,$port) = ($1,$2,$3);
        $port = 3333 if(!$port);
        push(@{$lk{data}{plugin}{'Foobar'}{servers}}, {'name' => $name, 'host' => $host, 'port' => $port});
        &{$lk{plugin}{'Foobar'}{code}{unload}}; &{$lk{plugin}{'Foobar'}{code}{load}};
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Added to server list.");
      }
    },
    '^NP list$' => {
      'tags' => ['utility','media'],
      'description' => "Lists available Foobar2000 servers.",
      'access' => 3,
      'code' => sub {
        my $i = 0;
        foreach(@{$lk{data}{plugin}{'Foobar'}{servers}}) {
          my $safeIP = ${$_}{host};
          $safeIP =~ s/^(.+?\..+?\.).+/$1\*\.\*/;
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"$i: [\x04${$_}{name}\x04] $safeIP:${$_}{port}");
          $i++;
        }
      }
    },
    '^NP del (\d+)$' => {
      'tags' => ['utility','media'],
      'description' => "Deletes a server.",
      'access' => 1,
      'code' => sub {
        my $id = $1;
        if($lk{data}{plugin}{'Foobar'}{servers}[$id]) {
          delete $lk{data}{plugin}{'Foobar'}{servers}[$id];
          @{$lk{data}{plugin}{'Foobar'}{servers}} = grep(!/^$/, @{$lk{data}{plugin}{'Foobar'}{servers}});
          &{$lk{plugin}{'Foobar'}{code}{unload}}; &{$lk{plugin}{'Foobar'}{code}{load}};
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Removed from server list.");
        }
        else {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"No server found with that ID");
        }
      }
    },
  }
});