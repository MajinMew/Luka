Luka
==
##What is Luka?
An IRC bot written in Perl, very original idea.

It features a modular "plugins" system allowing for infinite yet diverse functionality based on usage scenario backed by a supportive framework.

##Getting Started
Luka is programmed on and with [DWIM Perl](http://dwimperl.com/) in mind. Mileage may vary out-of-the-box with other flavors.

Luka uses a set of modules for her core functions, those being *Cwd*, *IO::Select*, *IO::Socket*, *utf-8* and *JSON*. If you don't have those installed already, you're going to need to in order to get the bot running. Depending on your perl setup, installation varies but it's likely you're able to use cpan to get these so check that out.
Some plugins require modules of their own, however when those dependencies aren't resolved, the plugins won't be loaded and you'll be informed in Luka's output. Most plugins are designed to be optional, so it's likely you can ignore those, unless you plan on using those plugins somehow.

It's best that you have git commands installed, and have it properly configured, because there is a git plugin on luka which allows you to check for updates, pull those udates, or even push your own code right from IRC. 

If perl is your path run the appropriate run-*.* file based on your operating system.
If perl is not in your path run **Luka.pl** manually however you can.

##Creating Plugins
Luka will read any file in the Plugins subdirectory and execute it as perl code; allowing you to add in plugins with the *addPlug* subroutine.

###addPlug syntax
This subroutine takes two arguments, a key for your plugin, and a hash containing all the things that make your plugin cooler than other plugins.
```perl
addPlug('My_Cool_Plugin', {
  'name' => "An example plugin, for GitHub.",
  'version' => 1,
  'description' => "Just a plugin that may or may not actually work",
  'creator' => "Caaz",
  'dependencies' => ['Core_Utilities','Core_Commands','Fancify'],
  'modules' => ['LWP::Get'],
  'commands' => {
    '^Get (.+)$' => {
      'access' => 1,
      'description' => 'Gets content from a URL',
      'code' => sub {
        lkDebug(get($1));
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Grabbed content and threw it to lkDebug");
      },
    }
  },
});
```
If your plugin's key conflicts there will be an error in STDOUT and Luka will use whichever plugin was last added.
The hash can contain whatever you want it to contain, however there are some keys which are used by other plugins to make things easier for everyone.

All of the keys are optional besides name, subject to become optional sooner or later.

####Dependencies
This sample plugin makes use of three other plugins; *Core\_Utilities*, *Core\_Commands* and *Fancify*. They're listed in the dependencies array. If any of those plugins weren't available, this sample plugin wouldn't load and output an appropriate error message.
The *modules* key works in a smiliar manner, but with perl modules instead.
####Core\_Commands
The reason for requiring *Core\_Commands* is that it allows the use of the commands key. This key contains a hash which the *Core\_Commands* plugin reads from, and uses in it's code to unify all of Luka's commands under one section of the code.

The keys in the command hash are regex, which is what Core\_Commands looks at and if they match, it'll execute the code in the hash of your regex...
* access
  * This key uses the Userbase plugin, and checks if the user has an access value equal to or above this value before continuing. If the user doesn't match, then an error message is displayed instead.
* cooldown
  * This key specifies that the command can't be used for x amount of seconds before it's used again.
* code
  * This is the code that's activated when the regex is matched, if it exists at least. 
* tags
  * This array is used for tags on the commands listing page, if you're using it.
* description
  * This string is used for descriptions in the command listing page, and hopefully a help command in the future.
