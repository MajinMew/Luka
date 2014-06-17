addPlug('Git', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Github via Luka',
  'dependencies' => ['Fancify','Core_Utilities'],
  'modules' => ['Sys::Hostname'],
  'description' => "This plugin was created to easily push updates from Luka onto the main branch.",
  'commands' => {
    '^Git push$' => {
      'description' => "Pushes latest updates to Github",
      'access' => 3,
      'tags' => ['utility'],
      'code' => sub {
        system('git add *.pl');
        system('git commit -m "Automated push from '.hostname().'"');
        system('git push');
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Pushed latest updates to >>Github");
      }
    }
  }
});