package backend;

#if sys
import sys.FileSystem;
import sys.io.File;
#else
import lime.utils.Assets;
#end
import tjson.TJSON as Json;

typedef ModsList = {
	enabled:Array<String>,
	disabled:Array<String>,
	all:Array<String>
};

class Mods
{
	static public var currentModDirectory:String = '';
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements',
		'lumod',
		'mobile'
	];

	/**
	 * CNE-style mod flags parsed from config/modpack or flags.ini.
	 * Outer key = mod name, value = raw INI content.
	 */
	public static var cneModRawConfigs:Map<String, String> = [];

	/**
	 * CNE-style state redirects parsed from [StateRedirects] section
	 */
	public static var cneStateRedirects:Map<String, String> = [];

	private static var globalMods:Array<String> = [];

	inline public static function getGlobalMods()
		return globalMods;

	inline public static function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		for(mod in parseList().enabled)
		{
			var pack:Dynamic = getPack(mod);
			if(pack != null && pack.runsGlobally) globalMods.push(mod);
		}
		return globalMods;
	}

	inline public static function getModDirectories():Array<String>
	{
		var list:Array<String> = [];
		#if MODS_ALLOWED
		var modsFolder:String = Paths.mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder))
			{
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder.toLowerCase()) && !list.contains(folder))
					list.push(folder);
			}
		}
		#end
		return list;
	}
	
	inline public static function mergeAllTextsNamed(path:String, defaultDirectory:String = null, allowDuplicates:Bool = false)
	{
		if(defaultDirectory == null) defaultDirectory = Paths.getPreloadPath();
		defaultDirectory = defaultDirectory.trim();
		if(!defaultDirectory.endsWith('/')) defaultDirectory += '/';
		if(!defaultDirectory.startsWith('assets/')) defaultDirectory = 'assets/$defaultDirectory';

		var mergedList:Array<String> = [];
		var paths:Array<String> = directoriesWithFile(defaultDirectory, path);

		var defaultPath:String = defaultDirectory + path;
		if(paths.contains(defaultPath))
		{
			paths.remove(defaultPath);
			paths.insert(0, defaultPath);
		}

		for (file in paths)
		{
			var list:Array<String> = CoolUtil.coolTextFile(file);
			for (value in list)
				if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
					mergedList.push(value);
		}
		return mergedList;
	}

	inline public static function directoriesWithFile(path:String, fileToFind:String, mods:Bool = true)
	{
		var foldersToCheck:Array<String> = [];
		if(FunkinFileSystem.exists(path + fileToFind))
			foldersToCheck.push(path + fileToFind);

		#if MODS_ALLOWED
		if(mods)
		{
			// Global mods first
			for(mod in Mods.getGlobalMods())
			{
				var folder:String = Paths.mods(mod + '/' + fileToFind);
				if(FileSystem.exists(folder)) foldersToCheck.push(folder);
			}

			// Then "PsychEngine/mods/" main folder
			var folder:String = Paths.mods(fileToFind);
			if(FileSystem.exists(folder)) foldersToCheck.push(Paths.mods(fileToFind));

			// And lastly, the loaded mod's folder
			if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			{
				var folder:String = Paths.mods(Mods.currentModDirectory + '/' + fileToFind);
				if(FileSystem.exists(folder)) foldersToCheck.push(folder);
			}
		}
		#end
		return foldersToCheck;
	}

	public static function getPack(?folder:String = null):Dynamic
	{
		#if MODS_ALLOWED
		if(folder == null) folder = Mods.currentModDirectory;

		var path = Paths.mods(folder + '/pack.json');
		if(FileSystem.exists(path)) {
			try {
				#if sys
				var rawJson:String = File.getContent(path);
				#else
				var rawJson:String = Assets.getText(path);
				#end
				if(rawJson != null && rawJson.length > 0) return Json.parse(rawJson);
			} catch(e:Dynamic) {
				trace(e);
			}
		}
		#end
		return null;
	}

	public static var updatedOnState:Bool = false;
	inline public static function parseList(?sortByPriority:Bool = false):ModsList {
		if(!updatedOnState) updateModList();
		var list:ModsList = {enabled: [], disabled: [], all: []};

		#if MODS_ALLOWED
		try {
			final toSortModList:Array<Dynamic> = sortByPriority ? [] : null;

			for (mod in CoolUtil.coolTextFile('modsList.txt'))
			{
				//trace('Mod: $mod');
				if(mod.trim().length < 1) continue;

				var dat = mod.split("|");

				if (sortByPriority) {
					toSortModList.push([dat[0], dat[1] == "1"]);
					continue;
				}
				
				list.all.push(dat[0]);
				if (dat[1] == "1")
					list.enabled.push(dat[0]);
				else
					list.disabled.push(dat[0]);
			}

			if (sortByPriority) {
				var packMap:Map<String, Dynamic> = new Map();
				function getPackCached(mod:String) {
					var v = packMap.get(mod);
					if (v == null) {
						final pack:Dynamic = getPack(mod);
						if (pack == null)
							return null;
						v = pack;
						packMap.set(mod, v);
					}
					return v;
				}

				function getModName(folder:String, pack:Dynamic):String {
					if(pack != null) {
						if((pack?.name ?? '').trim().length > 0)
						{
							if(pack.name != 'Name')
								return pack.name;
							else
								return pack.folder;
						}
					}
					return folder;
				}

				toSortModList.sort((a:Array<Dynamic>, b:Array<Dynamic>) -> {
					final modA = getPackCached(a[0]);
					final modB = getPackCached(b[0]);
					
					if (modA?.runsGlobally != modB?.runsGlobally) {
						return (modB?.runsGlobally ? 1 : 0) - (modA?.runsGlobally ? 1 : 0);
					}

					if (a[1] != b[1]) {
						return (b[1] == true ? 1 : 0) - (a[1] == true ? 1 : 0);
					}

					// final modACharCode = getModName(a[0], modA).trim().toLowerCase().charCodeAt(0);
					// final modBCharCode = getModName(b[0], modB).trim().toLowerCase().charCodeAt(0);
					// return modBCharCode < modACharCode ? 1 : -1;
					return 0;
				});

				for (modArray in toSortModList) {
					list.all.push(modArray[0]);
					if (modArray[1])
						list.enabled.push(modArray[0]);
					else
						list.disabled.push(modArray[0]);
				}

				packMap.clear();
				packMap = null;
			}
		} catch(e) {
			trace(e);
			trace(e.details());
		}
		#end
		return list;
	}
	
	private static function updateModList()
	{
		#if MODS_ALLOWED
		// Find all that are already ordered
		var list:Array<Array<Dynamic>> = [];
		var added:Array<String> = [];
		try {
			for (mod in CoolUtil.coolTextFile('modsList.txt'))
			{
				var dat:Array<String> = mod.split("|");
				var folder:String = dat[0];
				if(folder.trim().length > 0 && FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) && !added.contains(folder))
				{
					added.push(folder);
					list.push([folder, (dat[1] == "1")]);
				}
			}
		} catch(e) {
			trace(e);
		}
		
		// Scan for folders that aren't on modsList.txt yet
		for (folder in getModDirectories())
		{
			if(folder.trim().length > 0 && FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) &&
			!ignoreModFolders.contains(folder.toLowerCase()) && !added.contains(folder))
			{
				added.push(folder);
				list.push([folder, true]); //i like it false by default. -bb //Well, i like it True! -Shadow Mario (2022)
				//Shadow Mario (2023): What the fuck was bb thinking
			}
		}

		// Now save file
		var fileStr:String = '';
		for (values in list)
		{
			if(fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0');
		}

		File.saveContent('modsList.txt', fileStr);
		updatedOnState = true;
		//trace('Saved modsList.txt');
		#end
	}

	public static function loadTopMod()
	{
		Mods.currentModDirectory = '';
		
		#if MODS_ALLOWED
		var list:Array<String> = Mods.parseList().enabled;
		if(list != null && list[0] != null)
			Mods.currentModDirectory = list[0];
		#end
	}

	static var tempArray:Array<Dynamic> = [];
	public static function listStages(?allMods:Bool = false):Array<Array<String>> {
		tempArray = [];

		#if MODS_ALLOWED
		var directories:Array<String> = [
			Paths.mods('stages/'),
			Paths.mods(Mods.currentModDirectory + '/stages/'),
			Paths.getPreloadPath('stages/')
		];
		for (mod in (allMods ? Mods.parseList().enabled : Mods.getGlobalMods()))
			directories.push(Paths.mods(mod + '/stages/'));
		#else
		var directories:Array<String> = [Paths.getPreloadPath('stages/')];
		#end

		var stageFile:Array<String> = Mods.mergeAllTextsNamed('data/stageList.txt', Paths.getPreloadPath());
		var stages:Array<String> = [];
		var stagePaths:Array<String> = [];
		for (stage in stageFile) {
			if (stage.trim().length > 0) {
				stages.push(stage);
				stagePaths.push('');
			}
			tempArray.push(stage);
		}
		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if (FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var stageToCheck:String = file.substr(0, file.length - 5);
						if (stageToCheck.trim().length > 0 && !tempArray.contains(stageToCheck)) {
							tempArray.push(stageToCheck);
							stages.push(stageToCheck);
							stagePaths.push(directory.substr('mods/'.length, directory.length - ('/stages/'.length + 'mods/'.length)));
						}
					}
				}
			}
		}
		#end

		if (stages.length < 1) {
			stages.push('stage');
			stagePaths.push('');
		}

		return [stages, stagePaths];
	}

	// ============================================================
	// CNE-style mod configuration support
	// ============================================================

	/**
	 * Loads CNE-style mod configuration (config/modpack or flags.ini) for all enabled mods.
	 * Parses [Common], [Discord], [Flags], and [StateRedirects] sections.
	 */
	public static function loadCNEConfigs() {
		cneModRawConfigs.clear();
		cneStateRedirects.clear();

		var list = parseList();
		for (mod in list.enabled) {
			loadCNEConfigForMod(mod);
		}
	}

	/**
	 * Loads CNE-style mod configuration for a single mod.
	 * Looks for config/modpack first, then data/config/flags.ini.
	 */
	public static function loadCNEConfigForMod(mod:String) {
		#if MODS_ALLOWED
		var configPath:String = null;
		var modpackPath:String = Paths.mods('$mod/config/modpack');
		if (FileSystem.exists(modpackPath)) {
			configPath = modpackPath;
		} else {
			var flagsPath:String = Paths.mods('$mod/data/config/flags.ini');
			if (FileSystem.exists(flagsPath)) {
				configPath = flagsPath;
			}
		}

		if (configPath == null) return;

		try {
			var content:String = File.getContent(configPath);
			if (content == null || content.length == 0) return;

			cneModRawConfigs.set(mod, content);

			// Extract state redirects from the INI content
			var currentSection:String = null;
			for (line in content.split("\n")) {
				line = line.trim();
				if (line.length == 0 || line.charAt(0) == "#" || line.charAt(0) == ";") continue;

				if (line.charAt(0) == "[" && line.charAt(line.length - 1) == "]") {
					currentSection = line.substring(1, line.length - 1).trim();
					continue;
				}

				if (currentSection == "StateRedirects" || currentSection == "StateRedirects.force") {
					var eqIndex = line.indexOf("=");
					if (eqIndex > 0) {
						var key = line.substring(0, eqIndex).trim();
						var value = line.substring(eqIndex + 1).trim();
						if (currentSection == "StateRedirects.force" || !cneStateRedirects.exists(key))
							cneStateRedirects.set(key, value);
					}
				}
			}
		} catch (e) {
			trace('Error loading CNE config for mod "$mod": $e');
		}
		#end
	}

	/**
	 * Gets the resolved CNE state redirect for a given state name.
	 * Returns null if no redirect exists.
	 */
	public static function getCNEStateRedirect(stateName:String):String {
		return cneStateRedirects.get(stateName);
	}

	/**
	 * Gets CNE mod flags for a specific mod by parsing the raw INI content.
	 * Returns a map of "section.key" -> value pairs.
	 */
	public static function getCNEFlags(mod:String):Map<String, String> {
		var raw = cneModRawConfigs.get(mod);
		if (raw == null) return null;
		var result:Map<String, String> = [];
		var currentSection:String = null;
		for (line in raw.split("\n")) {
			line = line.trim();
			if (line.length == 0 || line.charAt(0) == "#" || line.charAt(0) == ";") continue;
			if (line.charAt(0) == "[" && line.charAt(line.length - 1) == "]") {
				currentSection = line.substring(1, line.length - 1).trim();
				continue;
			}
			var eqIndex = line.indexOf("=");
			if (eqIndex > 0) {
				var key = line.substring(0, eqIndex).trim();
				var value = line.substring(eqIndex + 1).trim();
				if ((value.charAt(0) == '"' && value.charAt(value.length - 1) == '"') ||
					(value.charAt(0) == "'" && value.charAt(value.length - 1) == "'"))
					value = value.substring(1, value.length - 1);
				var fullKey = (currentSection != null ? currentSection + "." : "") + key;
				result.set(fullKey, value);
			}
		}
		return result;
	}

	/**
	 * Gets a specific CNE flag value across all mods (first match wins).
	 */
	public static function getCNEFlag(flagName:String):String {
		for (mod => raw in cneModRawConfigs) {
			if (raw == null) continue;
			var currentSection:String = null;
			var sectionsToCheck = ["Common", "Flags", ""];
			var inTargetSection = false;

			for (line in raw.split("\n")) {
				line = line.trim();
				if (line.length == 0 || line.charAt(0) == "#" || line.charAt(0) == ";") continue;

				if (line.charAt(0) == "[" && line.charAt(line.length - 1) == "]") {
					currentSection = line.substring(1, line.length - 1).trim();
					inTargetSection = sectionsToCheck.contains(currentSection);
					continue;
				}

				if (inTargetSection) {
					var eqIndex = line.indexOf("=");
					if (eqIndex > 0) {
						var key = line.substring(0, eqIndex).trim();
						if (key == flagName) {
							var value = line.substring(eqIndex + 1).trim();
							if ((value.charAt(0) == '"' && value.charAt(value.length - 1) == '"') ||
								(value.charAt(0) == "'" && value.charAt(value.length - 1) == "'"))
								value = value.substring(1, value.length - 1);
							return value;
						}
					}
				}
			}
		}
		return null;
	}
}