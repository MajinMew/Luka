"Resources/CommandCam" /filename %1.bmp
"Resources/BMP2JPG" %1.bmp %1.jpg
move %1.jpg "C:/Users/%username%/Dropbox/Public/Pictures/%1.jpg"
del *.bmp