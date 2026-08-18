package funkin.backend.utils;

import lime.graphics.Image;
import openfl.Lib;
import lime.app.Application;

class WindowUtils {
	public static var winTitle:String = "Friday Night Funkin'";

	public static function setIconFromBytes(bytes:haxe.io.Bytes) {
		#if windows
		try {
			var img = Image.fromBytes(bytes);
			if (img != null) {
				Application.current.window.setIcon(img);
			}
		} catch (e:Dynamic) {}
		#end
	}
}
