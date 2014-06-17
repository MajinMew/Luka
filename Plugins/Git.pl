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
    },
    '^Git status$' => {
      'description' => "Pushes latest updates to Github",
      'access' => 3,
      'tags' => ['utility'],
      'code' => sub {
        system('git add *.pl');
        my @output = split /\n|\r/, `git status`;
        my @files = ();
        foreach(@output) {
          chomp($_);
          if(/\#\s+modified\:\s+(.+)$/) {
            my $name = $1;
            $name =~ s/.+[\\\/](.+)/$1/g;
            push(@files,$1);
          }
        }
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>".@files." files are modified and ready to be pushed. [\x04".(join "\x04] [\x04", @files)."\x04]");
      }
    }
  }
});