addPlug('Git', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Github via Luka',
  'dependencies' => ['Fancify','Core_Utilities'],
  'modules' => ['Sys::Hostname'],
  'description' => "This plugin was created to easily push updates from Luka onto the main branch.",
  'utilities' => {
    'add' => {
    }
  },
  'commands' => {
    '^Git$' => {
      'description' => "Links to the repository.",
      'code' => sub {
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Luka's Source is over here: https://github.com/Caaz/Luka");
      },
    },
    '^Git push( .+)?$' => {
      'description' => "Pushes latest updates to Github",
      'access' => 3,
      'tags' => ['utility'],
      'code' => sub {
        my $message = $1;
        if(!$message) { $message = 'Automated push from '.hostname(); }
        else { $message =~ s/^\s//g; $message =~ s/\"/\\\"/g; }
        system('git add *.pl');
        system('git add *.bat');
        system('git commit -m "'.$message.'"');
        ## This doesn't work... it'll try to push but it's not getting output.
        my @output = split /\n|\r/, `git push`;
        my $error = 0;
        foreach(@output) {
          chomp($_);
          lkDebug('Got: "'.$_.'"');
          if(/Rejected/i) { lkDebug("Error"); $error = 1; }
        }
        if($error) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Pushed failed. Need to \x04git pull\x04 first.");
        }
        else {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Pushed latest updates to >>Github with message \x04\"$message\"\x04");
        }
      }
    },
    '^Git pull$' => {
      'description' => "Pulls latest updates from Github",
      'access' => 3,
      'tags' => ['utility'],
      'code' => sub {
        my @output = split /\n|\r/, `git pull`;
        my $changes = 0;
        foreach(@output) {
          chomp($_);
          lkDebug($_);
          if(/(\d) files? changed/i) {
            my $changes = $1;
          }
        }
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Pulled latest updates from >>Github. $changes changes made.");
      }
    },
    '^Git status$' => {
      'description' => "Compares the local Luka to the Luka on Git to see what's new or something like that.",
      'access' => 3,
      'tags' => ['utility'],
      'code' => sub {
        system('git add *.pl'); system('git add *.bat');
        my @output = split /\n|\r/, `git status`;
        my @files = ();
        foreach(@output) {
          chomp($_);
          lkDebug('Got: '.$_);
          if(/\#\s+modified\:\s+(.+)$/) {
            my $name = $1;
            $name =~ s/.+[\\\/](.+)/$1/g;
            push(@files,$1);
          }
        }
        if(@files) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"There are >>".@files." files modified and ready to be pushed. [\x04".(join "\x04] [\x04", @files)."\x04]");
        }
        else {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"There are no files modified. Everything is synced up!");
        }
      }
    }
  }
});