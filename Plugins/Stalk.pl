addPlug('Stalk', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'The Stalk Suite',
  'dependencies' => ['Fancify','Core_Utilities'],
  'modules' => ['Sys::Hostname'],
  'description' => "This plugin adds in the ability to grab images from a webcam or take a screenshot. Will I add more functions? Possibly.",
  
  # This whole thing needs to be rewrote. It's terrible.
  
  'commands' => {
    '^Stalk(\d)?$' => {
      'description' => "Takes a picture using an available webcam.",
      'cooldown' => 3,
      'tags' => ['misc','utility'],
      'code' => sub {
        my $fname = time;
        my @text = ("Uploading...","Whenever this uploads...","Prepare for trouble.","It's not what you're thinking I swear.","Selfies intensify","NAILED IT.","Unsuspicious Webcam LED...","Papparazi mode activated.","That Face When.", "A wild Caaz appeared!");
        if($lk{os} =~ /MSWin32/) {
          system('"Resources/Stalk.bat" '.$fname);
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"$text[rand @text] https://dl.dropboxusercontent.com/u/9305622/Pictures/".$fname.".jpg");
        }
        elsif($lk{os} =~ /android/) { 
          $lk{droid}->cameraCapturePicture("/storage/sdcard0/Dropbox/$fname.jpg");
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"$text[rand @text] https://dl.dropboxusercontent.com/u/9305622/Pictures/".$fname.".jpg");
        }
      }
    },
    '^OmegaStalk$' => {
      'description' => "Screenshots!",
      'tags' => ['misc','utility'],
      'cooldown' => 3,
      'code' => sub {
        my $fname = "Scr-".(time);
        if($lk{os} =~ /MSWin32/) {
          system('"Resources/nircmd.exe" savescreenshot "C:/Users/%username%/Dropbox/Public/Screenshots/'.$fname.'.jpg"');
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Screenshot from ". hostname() .". https://dl.dropboxusercontent.com/u/9305622/Screenshots/".$fname.".jpg");
        }
      }
    }
  }
});