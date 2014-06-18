@echo off
:start_luka
perl ./Luka.pl
echo ---
set /P restart=Restart Luka? (yes) 
If /I "%restart%"=="yes" goto start_luka