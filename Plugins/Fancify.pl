addPlug("Fancify", {
  'creator' => 'Caaz',
  'version' => '3',
  'name' => 'Fancify',
  'dependencies' => ['Core_Command'],
  'commands' => {
    '^Fancify (\d{1,2}, \d{1,2})$' => {
      'description' => "Changes Fancify colors.",
      'access' => 3,
      'code' => sub {
        my @colors = split /\,/, $1;
        foreach(@colors) { $color = '0'.$color if($color<10); }
        @{$lk{data}{plugins}{'Fancify'}{colors}} = @colors;
        &{$lk{plugin}{"Fancify"}{utilities}{say}}($_[1]{irc},$_[2]{parsed},"Updated colors");
      }
    }
  },
  'utilities' => {
    'main' => sub {
      my @colors;
      if(@{$lk{data}{plugins}{'Fancify'}{colors}}) {
        @colors = @{$lk{data}{plugins}{'Fancify'}{colors}};
      }
      else { @colors = (14,13); }
      my $color = 0;
      my $string = "\cC$colors[0]".$_[0];
      my @string = split //, $string;
      foreach(@string) { if(/\x04/) { $color++; if($color >= @colors) { $color = 0; } $_ = "\cC$colors[$color]"; } }
      $string = join "", @string;
      $string =~ s/(\#[\w]+)/\cC$colors[1]$1\cC$colors[0]/g;
      $string =~ s/([a-z0-9]+:\/\/\S+\.[a-z]{2,6}\/?\S*?)/\cC$colors[1]$1\cC$colors[0]/g;
      $string =~ s/\|/\cC$colors[1]\|\cC$colors[0]/g;
      $string =~ s/(?:\x05|>>)([\w]+)/\cC$colors[1]$1\cC$colors[0]/g;
      $string =~ s/\cC\d{1,2}(?:,\d{1,2})?(\cC\d{1,2}(?:,\d{1,2})?)/$1/g;
      return $string;
    },
    'say' => sub {
      # Filehandle, Where, What.
      lkRaw($_[0],"PRIVMSG $_[1] :".&{$lk{plugin}{'Fancify'}{utilities}{main}}($_[2]));
    },
    'action' => sub {
      # Filehandle, Where, What.
      lkRaw($_[0],"PRIVMSG $_[1] :\x01ACTION ".&{$lk{plugin}{'Fancify'}{utilities}{main}}($_[2])."\x01");
    }
  }
});