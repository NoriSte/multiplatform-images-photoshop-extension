multiplatform-images-photoshop-extension
========================================

A basic extension for Photoshop that resize all the given images to lot of different resolutions, useful for multiplatform development when you have to support lot of device screens

Starting from wherever you want on your disk it creates some images in
.../320/photos/one.png
.../768/photos/one.png
.../1536/photos/one.png
starting from
.../originals/photos/one.png

or
.../800/photos/mountains/everest/NAME.png
from
.../originals/photos/mountains/everest/NAME.png

the only thing that matter is the "original" directory.

I created it for myself when developing an app for iOS/Android using Adobe AIR and Starling.
The extension works on all the opened files, unchanged ones will be closed.
All the opened images that are in a directory called "originals" or in whatever subdirectory of "originals" will be scaled and saved in directories called with the resolution name replicating the same directories structure.
If the processing image is bigger than 2048 it creates two images instead of one to respect the 2048 texture limit of Stage3D.

The extension must be opened with Flash Builder 4.6 and compiled with the Extension Builder installed. Debuggin it you will find it directly in Photoshop.

It's pretty easy to refactor the extension in Javascript to support the new Extension Builder included into the Adobe Creative Cloud.

[Extensions API](http://cssdk.host.adobe.com/sdk/1.0/docs/WebHelp/references/csawlib/)
[Scripting Photoshop tutorial](http://cssdk.host.adobe.com/sdk/1.0/docs/WebHelp/app_notes/ps_scripting.htm)