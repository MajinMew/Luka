addPlug('Digest', {
  'creator' => 'Caaz',
  'version' => '1',
  'description' => "Allows quick and easy encryption with different salts generated and saved to plugin stuff. This allows for different encryptions per bot.",
  'name' => 'Digest',
  'modules' => ['Digest::Bcrypt','Digest'],
  'utilities' => {
    'bcrypt' => sub {
      #Input: Data, Salt
      #Output: Digest, Salt
      my $bcrypt = Digest->new('Bcrypt');
      my $salt = '';
      my @shaker = (32..126); # Only things we can work with...
      if(!$_[1]) {
        lkDebug("Bcrypt: Generating new salt - No salt provided. ");
        foreach(0..15) { $salt .= chr($shaker[rand(@shaker)]); }
      }
      elsif($_[1] !~ /^\C{16}$/) {
        lkDebug("Bcrypt: Generating new salt - Salt isn't 16 octets.");
        foreach(0..15) { $salt .= chr($shaker[rand(@shaker)]); }
      }
      else { $salt = $_[1]; } # No issues with salt, using the argument instead.
      $bcrypt->cost(10);
      $bcrypt->salt($salt);
      $bcrypt->add($_[0]);
      return [$bcrypt->b64digest,$salt];
    },
  },
});