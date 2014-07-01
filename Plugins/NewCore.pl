addPlug('Core', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Core',
  'dependencies' => ['Fancify','Core_Utilities'],
  'description' => "A new Core plugin to replace old functions.",
  'utilities' => {
    'pluginAll' => sub {
      # Input: What
      foreach(keys %{$lk{plugin}}) { &{$lk{plugin}{$_}{code}{$_[0]}}({'data' => $lk{data}{plugin}{$_}, 'tmp' => $lk{tmp}{plugin}{$_}}) if($lk{plugin}{$_}{code}{$_[0]}); }
      return 1;
    },
    'restart' => sub { exec('perl Luka.pl'); },
    'reload' => sub {
      # Input: Type
      # 0 : Only load new plugins
      # 1 : Load all plugins
      my $startTime = time;
      if(!$_[0]) { &{$utility{'Core_pluginAll'}}('unload'); }
      elsif($_[0] == 1) { lkUnloadPlugins(); }
      return {'time'=>(time-$startTime),'errors' => lkLoadPlugins()};
    },
    'reloadSay' => sub {
      # Input: Handle, Where, Type
      my %return = %{&{$utility{'Core_reload'}}($_[2])};
      &{$utility{'Fancify_say'}}($_[0],$_[1],"Reloaded. [>>$return{time} ".&{$utility{'Caaz_Utilities_pluralize'}}("second", $return{time})."] [>>".@{$return{errors}}.' '.&{$utility{'Caaz_Utilities_pluralize'}}("error", @{$return{errors}})."]");
      foreach(@{$return{errors}}) {
        my @msg = split /\n/, ${$_}{message};
        @msg = grep !/^\s+?$/, @msg;
        &{$utility{'Fancify_say'}}($_[0],$_[1],"[\x04${$_}{plugin}\x04] ".(join " \x04|\x04 ", @msg));
      }
    }
  },
  'commands' => {
    '^Reload$' => {
      'description' => "Reloads any new code added to plugins.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { &{$utility{'Core_reloadSay'}}($_[1]{irc},$_[2]{where},0); }
    },
    '^Refresh$' => {
      'description' => "Reloads all plugins.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { &{$utility{'Core_reloadSay'}}($_[1]{irc},$_[2]{where},1); }
    },
    '^Restart$' => {
      'description' => "Restarts the entire bot.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { &{$utility{'Core_restart'}}(); }
    },
  }
});