package
{
	import com.adobe.csawlib.photoshop.Photoshop;
	import com.adobe.photoshop.*;

	import flash.filesystem.*;

	public class createMultiplatformImagesPsExtensionPhotoshop
	{
		public static var activeDocument:Document;
		public static var activeDocumentNativePath:String;
		public static var documentHeight:Number;
		public static var documentWidth:Number;

		// the original dimension of the images to resize
		public static var referenceScreen:Object = {
			height:1800
		};
		public static var rootDirectories:Array = File.getRootDirectories();

		// all the resolutions for which the extension should resize and scale the images
		public static var screens:Array = [{
				height:1800
			}, {
				height:1600
			}, {
				height:1536,
				width:2048
			}, {
				height:1020
			}, {
				height:800
			},/*{
				height:720
			},*/{
				height:768
			}, {
				height:600
			}, {
				height:480
			}, {
				height:320
			}
		];


		public static function run():void {
			var app:Application;
			var assetsContainer:File;
			var document:Document;
			var i:int;
			var n:int;
			var savedState:HistoryState;
			var screen:Object;

			app = Photoshop.app;

			while(document = app.activeDocument)
			{
				activeDocument = document;
				assetsContainer = document.path;

				// if the file is open but not saved on disk it will be closed without saving changes
				if(!document.path)
				{
					document.close(SaveOptions.DONOTSAVECHANGES);
					continue;
				}

				activeDocumentNativePath = document.path.nativePath;

				// checks the file directory
				if(findAssetsContainer(assetsContainer))
				{
					documentHeight = Number(document.height.toString().replace(" px", ""));
					documentWidth = Number(document.width.toString().replace(" px", ""));

					// creates the images for every given resolution
					n = screens.length;
					for(i = 0; i < n; i++)
					{
						savedState = document.activeHistoryState;
						screen = screens[i];
						cropAssetForScreen(screen.width, screen.height, referenceScreen.width, referenceScreen.height, assetsContainer);
						document.activeHistoryState = savedState;
					}
				}

				document.close(SaveOptions.DONOTSAVECHANGES);
			}
		}


		// all the opened images must have an "originals" directory in their parent directories
		public static function findAssetsContainer(directory:File):Boolean {
			var parent:File;
			var stopperFile:File;

			// if a parent directory doesn't exist the image cannot be saved
			if(!directory || rootDirectories.indexOf(directory) !== -1)
				return false;

			parent = directory;
			stopperFile = parent.resolvePath("originals");
			if(stopperFile.exists && stopperFile.isDirectory)
			{
				directory = parent;
				return true;
			}
			else
			{
				return findAssetsContainer(parent.parent);
			}
		}


		// the heart of the extension, it needs the screen to save the image for and the starting one
		public static function cropAssetForScreen(screenWidth:Number, screenHeight:Number, referenceScreenWidth:Number, referenceScreenHeight:Number, assetsContainer:File):void {
			var document:Document;
			var exportOptions:ExportOptionsSaveForWeb;
			var foldersToLoolFor:Array;
			var newHeight:Number;
			var newWidth:Number;
			var path:String;
			var pathToAssetsDirectory:String;
			var offsetFromX:Number;
			var savedState:HistoryState;

			document = activeDocument;
			exportOptions = new ExportOptionsSaveForWeb();
			exportOptions.format = SaveDocumentType.PNG;
			exportOptions.PNG8 = false;

			newHeight = documentHeight * screenHeight/referenceScreenHeight;
			newWidth = documentWidth * screenHeight/referenceScreenHeight;
			newHeight = Math.round(newHeight);
			newWidth = Math.round(newWidth);
			document.resizeImage(newWidth + " px", newHeight + " px", 72, ResampleMethod.BICUBICSHARPER);

			// if the screen width is being provided and the image is bigger than the width it will be cropped,
			// useful to keep the image into the texture size limit
			if(screenWidth && newWidth > screenWidth)
			{
				offsetFromX = (newWidth - screenWidth) / 2;
				offsetFromX |= 0;
				document.crop([offsetFromX, 0, offsetFromX + screenWidth, newHeight]);
			}

			foldersToLoolFor = assetsContainer.nativePath.split("originals/");
			if(foldersToLoolFor.length < 2)
				return;

			newWidth = Number(document.width.toString().replace(" px", ""));
			newHeight = Number(document.height.toString().replace(" px", ""));

			// if the images width is larger than 2048 (the base maximum width for every texture in AIR) it will be splitted
			// and two versions (named "<FILE_NAME>-left.png" and "<FILE_NAME>-right.png")
			if(newWidth > 2048)
			{
				savedState = document.activeHistoryState;

				document.crop([0, 0, 2048, newHeight]);
				path = foldersToLoolFor[0] + screenHeight.toString() + "/" + foldersToLoolFor[1];
				assetsContainer = new File(path);
				assetsContainer.createDirectory();
				document.exportDocument(assetsContainer.resolvePath(document.name.replace(".png", "-left.png")), ExportType.SAVEFORWEB, exportOptions);

				document.activeHistoryState = savedState;
				document.crop([2048, 0, newWidth, newHeight]);
				path = foldersToLoolFor[0] + screenHeight.toString() + "/" + foldersToLoolFor[1];
				assetsContainer = new File(path);
				assetsContainer.createDirectory();
				document.exportDocument(assetsContainer.resolvePath(document.name.replace(".png", "-right.png")), ExportType.SAVEFORWEB, exportOptions);
			}
			// else an image with the same name will be saved
			else
			{
				path = foldersToLoolFor[0] + screenHeight.toString() + "/" + foldersToLoolFor[1];
				assetsContainer = new File(path);
				assetsContainer.createDirectory();
				document.exportDocument(assetsContainer.resolvePath(document.name), ExportType.SAVEFORWEB, exportOptions);
			}
		}
	}
}