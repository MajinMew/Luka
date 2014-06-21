addPlug("Command_Helper", {
  'creator' => 'Caaz',
  'version' => '2',
  'description' => "This plugin is what lists commands in an HTML file. At first it wasn't important and was in the Misc file! Now it's gone on to bigger and better things. Possibly will do other things later.",
  'name' => 'Command Helper',
  'dependencies' => ['Core_Command','Fancify'],
  'utilities' => {
    'generateHTML' => sub {
      # Input: Handle, Where
      # Output: True if no problems.
      %custom = %{$lk{data}{plugin}{'Command_Helper'}};
      # image, Path to an image.
      # stylesheets, Array of paths to css files.
      # javascripts, Array of paths to javascript files.
      # output, Path to wherever the file should be saved at.
      # info, path to a .txt file which will explain your bot.
      # name, bot name text.
      # url, url to return.
      foreach('output','url') { 
        if(!$custom{$_}) { 
          &{$utility{'Fancify_say'}}($_[0],$_[1],"No >>$_ defined. Cannot build command list.");
          return 0;
        } 
      }
      my @html = ('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">','<head>','-head-','</head>','<body>','-body-','</body>','</html>');
      my $indent = 2;
      
      # Let's do headers first.
      my %content = ();
      @{$content{head}} = ('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
      if($custom{name}) { push(@{$content{head}},'<title>',$custom{name},'</title>'); }
      else { push(@{$content{head}},'<title>',$lk{version},'</title>'); } 
      foreach(@{$custom{javascripts}}) { push(@{$content{head}},'<script type="text/javascript" src="'.$_.'">','</script>'); }
      foreach(@{$custom{stylesheets}}) { push(@{$content{head}},'<link rel="stylesheet" type="text/css" href="'.$_.'" />'); }
      # Then the body
      
      # First, let's get bot info, if there is any.
      push(@{$content{body}},'<img class="mascot" src="'.$custom{image}.'" />') if $custom{image};
      push(@{$content{body}},'<div class="content">');
      push(@{$content{body}},'<div class="title">');
      if($custom{name}) { push(@{$content{body}},'<h2 class="name">',"$custom{name} Commands",'</h2>'); }
      else { push(@{$content{body}},'<h2 class="name">','Bot Commands','</h2>'); }
      push(@{$content{body}},'</div>');
      push(@{$content{body}},'<div class="info">');
      if($custom{info}) {
        open INFO, "<$custom{info}";
        while(<INFO>) { chomp($_); $_ =~ s/^\s//g; push(@{$content{body}},$_."<br />"); }
        close INFO;
      }
      else { 
        push(@{$content{body}},"This bot doesn't have any information! Tell the owner to set info to a filename for this to be filled in with its contents.");
      }
      push(@{$content{body}},'<div class="timestamp">','Command listing as of '.localtime(), '</div>', '</div>','</div>');
      
      # Grab command list, by plugin.
      my %commands;
      foreach $plugin (keys %{$lk{plugin}}) {
        foreach $regex (keys %{$lk{plugin}{$plugin}{commands}}) {
          push(@{$commands{$plugin}}, $regex) if $lk{plugin}{$plugin}{commands}{$regex}{description};
        }
      }
      # Sort the plugins by key. (Maybe I should do this by name instead.)
      my @plugins = sort keys %commands;
      foreach $plugin (@plugins) {
        push(@{$content{body}},'<div class="content">');
        push(@{$content{body}},'<div class="title">',$lk{plugin}{$plugin}{name});
        push(@{$content{body}},' v'.$lk{plugin}{$plugin}{version}) if $lk{plugin}{$plugin}{version};
        push(@{$content{body}},'</div>');
        # Get plugin information!
        push(@{$content{body}},'<div class="info">');
        foreach(['creator','Creator'],['description','Description']) {
          push(@{$content{body}},'<div class="'.${$_}[0].'">',${$_}[1].': '.$lk{plugin}{$plugin}{${$_}[0]},'</div>') if $lk{plugin}{$plugin}{${$_}[0]};
        }
        # Look at the commands!
        my @commands = sort @{$commands{$plugin}};
        foreach (@commands) {
          my $command = $_;
          my $com = $_;
          $com =~ s/^\^|\$$//g;
          $com = '^'.$lk{data}{prefix}.$com.'$';
          push(@{$content{body}},'<div class="command">');
          push(@{$content{body}},'<div class="regex">',$com);
          foreach(@{$lk{plugin}{$plugin}{commands}{$_}{tags}}) { push(@{$content{body}},'<span class="tag_'.$_.'">',$_,'</span>'); }
          foreach(['Access','access'],['Cooldown','cooldown']) {
            push(@{$content{body}},'<span class="tag_'.${$_}[1].'">', "${$_}[0]: ".$lk{plugin}{$plugin}{commands}{$command}{${$_}[1]}, '</span>') if $lk{plugin}{$plugin}{commands}{$command}{${$_}[1]};
          }
          push(@{$content{body}},'</div>','<div class="info">');
          foreach(['','description','p'],['Example: ','example','code']) {
            push(@{$content{body}},'<'.${$_}[2].' class="'.${$_}[1].'">', ${$_}[0].$lk{plugin}{$plugin}{commands}{$command}{${$_}[1]}, '</'.${$_}[2].'>') if $lk{plugin}{$plugin}{commands}{$command}{${$_}[1]};
          }
          push(@{$content{body}},'</div>','</div>');
        }
        push(@{$content{body}},'</div>');
        push(@{$content{body}},'</div>');
      }
        
      # Fill in the blanks, Mad-Lib style.
      my %strings = ('html' => join "\n", @html);
      foreach(keys %content) { $strings{$_} = join "\n", @{$content{$_}}; }
      $strings{html} =~ s/\-(\w+?)\-/$strings{$1}/g;
      # Change things back into an array and tab that shit.
      @html = split /\n/, $strings{html};
      my $tab = '';
      foreach (@html) {
        if(/\<[^\/].+?[^\/]\>/) { $_ = $tab.$_; $tab .= "\t"; } # Increase Tab
        elsif(/\<\/.+?\>/) { $tab =~ s/\t//; $_ = $tab.$_; } # Decrease Tab
        else { $_ = $tab.$_; } # No change
      }
      # Write it to the file!
      open HTML, ">$custom{output}"; print HTML join "\n", @html; close HTML;
      # Say the url!
      &{$utility{'Fancify_say'}}($_[0],$_[1],"View the command list here: $custom{url}");
      return 1;
    },
  },
  'commands' => {
    '^(?:Commands|Help|(?:Cinos|Isk)?LearnRegex)$' => {
      'description' => "Generates an HTML and gives a url to it.",
      'tags' => ['utility'],
      'code' => sub {
        &{$utility{'Command_Helper_generateHTML'}}($_[1]{irc},$_[2]{where});
      }
    }
  },
});