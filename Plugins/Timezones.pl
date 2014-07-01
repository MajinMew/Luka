addPlug('Timezone', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Timezones',
  'dependencies' => ['Fancify','Core_Utilities'],
  'description' => "This'll probably access timezones somehow",
  'modules' => ['DateTime','DateTime::TimeZone'],
  'commands' => {
    '^Time (.+)?$' => {
      'description' => "Checks time in a certain timezone.",
      'tags' => ['misc','utility'],
      'code' => sub {
        my $string = $1;
        my $dt = DateTime->now();
        my $tz;
        eval { $tz = DateTime::TimeZone->new( name => $string ); };
        if($@) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},$@);
          return 0;
        }
        $dt->set_time_zone($tz);
        my @time = ($dt->hour_12_0(),$dt->minute(),$dt->second());
        foreach(@time) { if((split //, $_) <= 1){ $_ = '0'.$_; } } 
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},$dt->month_name()." ".$dt->day().", ".(join ":", @time));
      }
    }
  }
});