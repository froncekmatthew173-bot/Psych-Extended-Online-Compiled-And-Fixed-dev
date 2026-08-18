package mobile;

import haxe.Json;
import haxe.io.Path;
import flixel.util.FlxSave;
import openfl.utils.Assets;

using StringTools;

class MobileConfig {
	public static var actionModes:Map<String, MobileButtonsData> = new Map();
	public static var dpadModes:Map<String, MobileButtonsData> = new Map();
	public static var hitboxModes:Map<String, CustomHitboxData> = new Map();
	public static var mobileFolderPath:String = 'mobile/';

	public static var save:FlxSave;
	public static function init(saveName:String, savePath:String, mobilePath:String = 'mobile/', folders:Array<Array<Dynamic>>)
	{
		save = new FlxSave();
		save.bind(saveName, savePath);
		if (mobilePath != null || mobilePath != '') mobileFolderPath = (mobilePath.endsWith('/') ? mobilePath : mobilePath + '/');

		for (folder in folders) {
			switch (folder[1]) {
				case ACTION:
					readDirectoryPart1(mobileFolderPath + folder[0], actionModes, ACTION);
					#if MODS_ALLOWED
					for (folder in Mods.directoriesWithFile(Paths.getPreloadPath(), 'mobile/MobilePad/')) {
						trace('called');
						readDirectoryPart1(Path.join([folder, 'ActionModes']), actionModes, ACTION);
					}
					#end
				case DPAD:
					readDirectoryPart1(mobileFolderPath + folder[0], dpadModes, DPAD);
					#if MODS_ALLOWED
					for (folder in Mods.directoriesWithFile(Paths.getPreloadPath(), 'mobile/MobilePad/')) {
						trace('called');
						readDirectoryPart1(Path.join([folder, 'DPadModes']), dpadModes, DPAD);
					}
					#end
				case HITBOX:
					readDirectoryPart1(mobileFolderPath + folder[0], hitboxModes, HITBOX);
					#if MODS_ALLOWED
					for (folder in Mods.directoriesWithFile(Paths.getPreloadPath(), 'mobile/Hitbox/')) {
						trace('called');
						readDirectoryPart1(Path.join([folder, 'HitboxModes']), hitboxModes, HITBOX);
					}
					#end
			}
		}
	}

	static function readDirectoryPart1(folder:String, map:Dynamic, mode:ButtonModes)
	{
		trace('' + folder);
		folder = folder.contains(':') ? folder.split(':')[1] : folder;

		#if mobile_controls_file_support if (FunkinFileSystem.exists(folder)) #end
		for (file in readDirectoryPart2(folder))
		{
			if (Path.extension(file) == 'json')
			{
				file = Path.join([folder, Path.withoutDirectory(file)]);

				var str:String;
				#if mobile_controls_file_support
				if (FunkinFileSystem.exists(file))
					str = FunkinFileSystem.getText(file);
				else #end
					str = Assets.getText(file);

				if (mode == HITBOX) {
					var json:CustomHitboxData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(file));
					map.set(mapKey, json);
				}
				else if (mode == ACTION || mode == DPAD) {
					var json:MobileButtonsData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(file));
					map.set(mapKey, json);
				}
			}
		}
	}

	static function readDirectoryPart2(directory:String):Array<String>
	{
		var dirs:Array<String> = [];

		#if mobile_controls_file_support
		return FunkinFileSystem.readDirectory(directory);
		#else
		var dirs:Array<String> = [];
		for(dir in Assets.list().filter(folder -> folder.startsWith(directory)))
		{
			@:privateAccess
			for(library in lime.utils.Assets.libraries.keys())
			{
				if(library != 'default' && Assets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
					dirs.push('$library:$dir');
				else if(Assets.exists(dir) && !dirs.contains(dir))
					dirs.push(dir);
			}
		}
		return dirs;
		#end
	}
}
