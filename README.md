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
