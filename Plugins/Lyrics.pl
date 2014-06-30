addPlug('Lyrics', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'description' => "Grabs Lyrics, hopefully from more than one source.",
  'name' => 'Lyrics',
  'dependencies' => ['Core_Command','Core_Utilities'],
  'utilities' => {
    'get' => sub {
      # Handle, Where, Search String
    },
  },
  'commands' => {
  },
});