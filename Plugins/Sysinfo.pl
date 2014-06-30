addPlug('System', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'description' => "It's for System information!",
  'name' => 'System Info',
  'dependencies' => ['Core_Command','Core_Utilities'],
  'utilities' => {
    'info' => sub {
      # Handle, Where
      if($lk{os} !~ /linux/i) { &{$utility{'Fancify_say'}}($_[0],$_[1],"Sorry, nothing's been set for \x04$lk{os}\x04 yet."); return 0; }
      my (@uname, @return, $usr, $avg, $up);
      @return = ();
      @uname = (split ' ', `uname -a`)[0..2];
      push(@return, "[Host: \x04$uname[1]\x04]", "[Running: \x04$uname[0] $uname[2]\x04]");
      if (`uptime` =~ /^.*?up\s*(.*?),\s*(\d+) users?,.*: ([\d\.]+)/){
        ($usr, $avg) = ($2, $3);
        ($up = $1) =~ s/\s*days?,\s*|\+/d+/;
        push(@return,"[Uptime: \x04$up\x04]","[Users: \x04$usr\x04]","[Load: \x04$avg\x04]");
      }
      # Free space
      if (`free` =~ /Mem:\s*(\d*)\s*\d*\s*(\d*)/) { push(@return,"[Memory: \x04". int(.5 + $2/2**10) ."\x04/\x04". int(.5 + $1/2**10) ."\x04 MiB]"); }
      if (`free` =~ /Swap:\s*(\d*)\s*\d*\s*(\d*)/) { push(@return,"[Swap: \x04". int(.5 + $2/2**10) ."\x04/\x04". int(.5 + $1/2**10) ."\x04 MiB]"); }

      for (`df -m -x nfs -x smbfs -x none`) { /^\/\S*\s*(\S*)\s*\S*\s*(\S*)\s*\S*\s*(\S*)/ and push(@return,"[$3: \x04$2\x04/\x04$1\x04 MiB]"); }
      &{$utility{'Fancify_say'}}($_[0],$_[1],join " ", @return);
      return 1;
    },
  },
  'commands' => {
    '^Sysinfo$' => {
      'description' => "Sets OAuth keys for Twitter usage.",
      'access' => 3,
      'code' => sub {
        &{$utility{'System_info'}}($_[1]{irc},$_[2]{where});
      }
    }
  },
});