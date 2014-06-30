addPlug('System', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'description' => "It's for System information!",
  'name' => 'System Info',
  'dependencies' => ['Core_Command','Core_Utilities'],
  'utilities' => {
    'info' => sub {
      my (@uname, $ret, $usr, $avg, $up);
    
      @uname = (split ' ', `uname -a`)[0..2];
      
      $ret = "Host '@uname[1]', running @uname[0] @uname[2] - ";
      if (`uptime` =~ /^.*?up\s*(.*?),\s*(\d+) users?,.*: ([\d\.]+)/){
        ($usr, $avg) = ($2, $3);
        ($up = $1) =~ s/\s*days?,\s*|\+/d+/;
        $ret .= "Up: $up; Users: $usr; Load: $avg; ";
      }
      # Free space
      $ret .= "Free:";
      if (`free` =~ /Mem:\s*(\d*)\s*\d*\s*(\d*)/) { $ret .= " [Mem: " . int(.5 + $2/2**10) . "/" . int(.5 + $1/2**10) . " Mio]"; } # For compatibility: replace $1 with $2
      if (`free` =~ /Swap:\s*(\d*)\s*\d*\s*(\d*)/) { $ret .= " [Swap: " . int(.5 + $2/2**10) . "/" . int(.5 + $1/2**10) . " Mio]"; } # For compatibility: replace $1 with $2

      for (`df -m -x nfs -x smbfs -x none`) {
        /^\/\S*\s*(\S*)\s*\S*\s*(\S*)\s*\S*\s*(\S*)/ and $ret .= " [$3: $2/$1 Mio]";
      }
      $ret .= ";";
      return $ret;
    },
  },
  'commands' => {
    '^Sysinfo$' => {
      'description' => "Sets OAuth keys for Twitter usage.",
      'access' => 3,
      'code' => sub {
        if($lk{os} =~ /^linux$/i) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'System_info'}}());
        }
        else {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Sorry, nothing's been set for \x04$lk{os}\x04 yet.");
        }
      }
    }
  },
});