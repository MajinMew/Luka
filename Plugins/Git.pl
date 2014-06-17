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
        my @output = split /\n|\r/, `git push`;
        foreach(@output) {
          chomp($_);
          lkDebug($_);
          if(/fetch first/) { $error = 1; }
        }
        if($error) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Pushed failed. Need to \x04git pull\x04 first.");
        }
        else {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Pushed latest updates to >>Github with message \"$message\"");
        }
      }
    },
    '^Git pull$' => {
      'description' => "Pushes latest updates to Github",
      'access' => 3,
      'tags' => ['utility'],
      'code' => sub {
        my @output = split /\n|\r/, `git pull`;
        my @files = ();
        foreach(@output) {
          chomp($_);
          lkDebug($_);
          if(/\#\s+modified\:\s+(.+)$/) {
            my $name = $1;
            $name =~ s/.+[\\\/](.+)/$1/g;
            push(@files,$1);
          }
        }
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Pulled latest updates from >>Github with message");
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
          lkDebug($_);
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