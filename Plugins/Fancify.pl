addPlug("Fancify", {
  'creator' => 'Caaz',
  'version' => '3',
  'name' => 'Fancify',
  'utilities' => {
    'main' => sub {
      my $string = "\cC14".$_[0];
      my @colors = ('14','13');
      my $color = 0;
      my @string = split //, $string;
      foreach(@string) { if(/\x04/) { $color++; if($color >= @colors) { $color = 0; } $_ = "\cC$colors[$color]"; } }
      $string = join "", @string;
      $string =~ s/(\#[\w]+)/\cC$colors[1]$1\cC$colors[0]/g;
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