addPlug('Digest', {
  'creator' => 'Caaz',
  'version' => '1',
  'description' => "Allows quick and easy encryption with different salts generated and saved to plugin stuff. This allows for different encryptions per bot.",
  'name' => 'Digest',
  'modules' => ['Digest::Bcrypt','Digest'],
  'utilities' => {
    'bcrypt' => sub {
      # Data
      my $bcrypt = Digest->new('Bcrypt');
      if(!$lk{data}{plugin}{'Digest'}{cost}) { lkDebug("Bcrypt: Generating new cost"); $lk{data}{plugin}{'Digest'}{cost} = int(rand(31))+1; }
      if(!$lk{data}{plugin}{'Digest'}{salt}) { lkDebug("Bcrypt: Generating new salt"); $lk{data}{plugin}{'Digest'}{salt} = ''; foreach(0..15) { $lk{data}{plugin}{'Digest'}{salt} .= chr(rand(256)); } }
      $bcrypt->cost($lk{data}{plugin}{'Digest'}{cost});
      $bcrypt->salt($lk{data}{plugin}{'Digest'}{salt});
      $bcrypt->add($_[0]);
      return $bcrypt->b64digest;
    },
  },
});