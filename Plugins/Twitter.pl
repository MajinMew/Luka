addPlug('Twitter', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'description' => "Something about Twitter functionality",
  'name' => 'Twitter',
  'dependencies' => ['Core_Command','Core_Utilities'],
  'modules' => ['OAuth::Consumer'],
  'utilities' => {
    'setUA' => sub {
      # Input: Server Name, Nickname
      my $ua = OAuth::Consumer->new(
        oauth_consumer_key => 'key',
        oauth_consumer_secret => 'secret',
        oauth_request_token_url => 'http://provider/oauth/request_token',
        oauth_authorize_url => 'http://provider/oauth/authorize',
        oauth_access_token_url => 'http://provider/oauth/access_token'
      );
    },
  },
  'commands' => {
    '^Twitter setKeys (.+?) (.+)$' => {
      'description' => "Sets OAuth keys for Twitter usage.",
      'access' => 3,
      'code' => sub {
        my ($key,$secret) = ($1,$2);
      }
    }
  },
});