addPlug('Userbase', {
  'creator' => 'Caaz',
  'version' => '1.2',
  'description' => "Better than Core_Users!",
  'name' => 'Virtual Pet Rock',
  'dependencies' => ['Core_Command','Core_Utilities'],
  'utilities' => {
  
  },
  'commands' => {
    '^ub register (.+?) (.+)$' => {
      'description' => "Registers a new userbase account.",
      'tags' => ['wip'],
      'access' => 3,
      'code' => sub {
        my ($key,$secret) = ($1,$2);
      }
    }
  },
});