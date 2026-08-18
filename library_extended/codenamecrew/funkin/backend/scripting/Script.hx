package   codenamecrew.codenamecrew.funkin.backend.scripting;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxStringUtil;
import haxe.io.Path;
import lime.app.Application;

@:allow(  codenamecrew.codenamecrew.funkin.backend.scripting.ScriptPack)
/**
 * Class used for scripting.
 * Use `Script.create` to create a script.
 */
class Script extends FlxBasic implements IFlxDestroyable {
	/**
	 * Use "static var thing = true;" in hscript to use those!!
	 * are reset every mod switch so once you're done with them make sure to make them null!!
	 */
	public static var staticVariables:Map<String, Dynamic> = [];

	/**
	 * Gets the default variables for a script.
	 */
	public static function getDefaultVariables(?script:Script):Map<String, Dynamic> {
		var vars = _defaultVariablesTemplate != null ? _defaultVariablesTemplate : (_defaultVariablesTemplate = buildDefaultVariables());
		var copy = vars.copy();
		copy.set("state", flixel.FlxG.state); // `state` changes on state switch, so it can't be cached
		copy.set("window", lime.app.Application.current.window); // same for `window`: evaluated at script creation time like before
		return copy;
	}

	/**
	 * Cached template of the default variables.
	 * Built once (including the `Type.resolveClass` lookups) and shallow-copied per script.
	 */
	private static var _defaultVariablesTemplate:Map<String, Dynamic> = null;

	private static function buildDefaultVariables():Map<String, Dynamic> {
		return [
			// Haxe related stuff
			"Std"				=> Std,
			"Math"				=> Math,
			"Reflect"			=> Reflect,
			"StringTools"		=> StringTools,
			"Json"				=> haxe.Json,
			"Xml"				=> Xml,
			"Type"				=> Type,
			"Date"				=> Date,
			"Lambda"			=> Lambda,
			#if sys "Sys"		=> Sys, #end

			// OpenFL & Lime related stuff
			"BlendMode"			=> CoolUtil.getMacroAbstractClass("openfl.display.BlendMode"),
			"Assets"			=> openfl.utils.Assets,
			"Application"		=> lime.app.Application,
			"Main"				=>   codenamecrew.codenamecrew.funkin.backend.system.Main,

			// Flixel related stuff
			"FlxG"				=> flixel.FlxG,
			"FlxSprite"			=> flixel.FlxSprite,
			"FlxBasic"			=> flixel.FlxBasic,
			"FlxCamera"			=> flixel.FlxCamera,
			"FlxEase"			=> flixel.tweens.FlxEase,
			"FlxTween"			=> flixel.tweens.FlxTween,
			"FlxSound"			=> flixel.sound.FlxSound,
			"FlxAssets"			=> flixel.system.FlxAssets,
			"FlxMath"			=> flixel.math.FlxMath,
			"FlxGroup"			=> flixel.group.FlxGroup,
			"FlxTypedGroup"		=> flixel.group.FlxGroup.FlxTypedGroup,
			"FlxSpriteGroup"	=> flixel.group.FlxSpriteGroup,
			"FlxTypeText"		=> flixel.addons.text.FlxTypeText,
			"FlxText"			=> flixel.text.FlxText,
			"FlxTimer"			=> flixel.util.FlxTimer,
			"FlxPoint"			=> CoolUtil.getMacroAbstractClass("flixel.math.FlxPoint"),
			"FlxAxes"			=> CoolUtil.getMacroAbstractClass("flixel.util.FlxAxes"),
			"FlxColor"			=> CoolUtil.getMacroAbstractClass("flixel.util.FlxColor"),

			// Engine related stuff
			"engine"			=> {
				commit: Flags.COMMIT_NUMBER,
				hash: Flags.COMMIT_HASH,
				build: 2675, // 2675 being the last build num before it was removed
				name: "Codename Engine"
			},
			"ModState"			=>   codenamecrew.codenamecrew.funkin.backend.scripting.ModState,
			"ModSubState"		=>   codenamecrew.codenamecrew.funkin.backend.scripting.ModSubState,
			"PlayState"			=>   codenamecrew.codenamecrew.funkin.game.PlayState,
			"GameOverSubstate"	=>   codenamecrew.codenamecrew.funkin.game.GameOverSubstate,
			"HealthIcon"		=>   codenamecrew.codenamecrew.funkin.game.HealthIcon,
			"HudCamera"			=>   codenamecrew.codenamecrew.funkin.game.HudCamera,
			"Note"				=>   codenamecrew.codenamecrew.funkin.game.Note,
			"Strum"				=>   codenamecrew.codenamecrew.funkin.game.Strum,
			"StrumLine"			=>   codenamecrew.codenamecrew.funkin.game.StrumLine,
			"Character"			=>   codenamecrew.codenamecrew.funkin.game.Character,
			"Boyfriend"			=>   codenamecrew.codenamecrew.funkin.game.Character, // for compatibility
			"PauseSubstate"		=>   codenamecrew.codenamecrew.funkin.menus.PauseSubState,
			"FreeplayState"		=>   codenamecrew.codenamecrew.funkin.menus.FreeplayState,
			"MainMenuState"		=>   codenamecrew.codenamecrew.funkin.menus.MainMenuState,
			"PauseSubState"		=>   codenamecrew.codenamecrew.funkin.menus.PauseSubState,
			"StoryMenuState"	=>   codenamecrew.codenamecrew.funkin.menus.StoryMenuState,
			"TitleState"		=>   codenamecrew.codenamecrew.funkin.menus.TitleState,
			"Options"			=>   codenamecrew.codenamecrew.funkin.options.Options,
			"Paths"				=>   codenamecrew.codenamecrew.funkin.backend.assets.Paths,
			"Conductor"			=>   codenamecrew.codenamecrew.funkin.backend.system.Conductor,
			"codenamecrew.funkin.Shader"		=>   codenamecrew.codenamecrew.funkin.backend.shaders.codenamecrew.funkin.Shader,
			"CustomShader"		=>   codenamecrew.codenamecrew.funkin.backend.shaders.CustomShader,
			"codenamecrew.funkin.Text"		=>   codenamecrew.codenamecrew.funkin.backend.codenamecrew.funkin.Text,
			"FlxAnimate"		=> animate.FlxAnimate,
			"codenamecrew.funkin.Sprite"		=>   codenamecrew.codenamecrew.funkin.backend.codenamecrew.funkin.Sprite,
			"Alphabet"			=>   codenamecrew.codenamecrew.funkin.menus.ui.Alphabet,
			"Flags"				=>   codenamecrew.codenamecrew.funkin.backend.system.Flags,

			"CoolUtil"			=>   codenamecrew.codenamecrew.funkin.backend.utils.CoolUtil,
			"IniUtil"			=>   codenamecrew.codenamecrew.funkin.backend.utils.IniUtil,
			"XMLUtil"			=>   codenamecrew.codenamecrew.funkin.backend.utils.XMLUtil,
			#if sys "ZipUtil"	=>   codenamecrew.codenamecrew.funkin.backend.utils.ZipUtil, #end
			"MarkdownUtil"		=>   codenamecrew.codenamecrew.funkin.backend.utils.MarkdownUtil,
			"EngineUtil"		=>   codenamecrew.codenamecrew.funkin.backend.utils.EngineUtil,
			"ThreadUtil"		=>   codenamecrew.codenamecrew.funkin.backend.utils.ThreadUtil,
			"MemoryUtil"		=>   codenamecrew.codenamecrew.funkin.backend.utils.MemoryUtil,
			"BitmapUtil"		=>   codenamecrew.codenamecrew.funkin.backend.utils.BitmapUtil,

			#if TRANSLATIONS_SUPPORT
			"TranslationUtil"	=>   codenamecrew.codenamecrew.funkin.backend.utils.TranslationUtil,
			"translate"		=>   codenamecrew.codenamecrew.funkin.backend.utils.TranslationUtil.get,
			#end
		];
	}

	/**
	 * Used internally to keep backwards compatibility with old scripts.
	 * This gets set on `hscript.Interp.importRedirects`,
	 * if you wanna modify it, please edit `hscript.Interp.importRedirects` directly.
	**/
	public static function getDefaultImportRedirects():Map<String, String> {
		var redirects:Map<String, String> = [];

		// Events
		final events = "  codenamecrew.codenamecrew.funkin.backend.scripting.events.";
		redirects[events + "CharacterNodeEvent"]			= events + "character.CharacterNodeEvent";
		redirects[events + "CharacterXMLEvent"]				= events + "character.CharacterXMLEvent";
		redirects[events + "DanceEvent"]					= events + "character.DanceEvent";
		redirects[events + "DirectionAnimEvent"]			= events + "character.DirectionAnimEvent";
		redirects[events + "DiscordPresenceUpdateEvent"]	= events + "discord.DiscordPresenceUpdateEvent";
		redirects[events + "GameOverCreationEvent"]			= events + "gameover.GameOverCreationEvent";
		redirects[events + "CamMoveEvent"]					= events + "gameplay.CamMoveEvent";
		redirects[events + "CountdownEvent"]				= events + "gameplay.CountdownEvent";
		redirects[events + "EventGameEvent"]				= events + "gameplay.EventGameEvent";
		redirects[events + "GameOverEvent"]					= events + "gameplay.GameOverEvent";
		redirects[events + "RatingUpdateEvent"]				= events + "gameplay.RatingUpdateEvent";
		redirects[events + "HealthIconChangeEvent"]			= events + "healthicon.HealthIconChangeEvent";
		redirects[events + "FreeplayAlphaUpdateEvent"]		= events + "menu.freeplay.FreeplayAlphaUpdateEvent";
		redirects[events + "FreeplaySongSelectEvent"]		= events + "menu.freeplay.FreeplaySongSelectEvent";
		redirects[events + "MenuChangeEvent"]				= events + "menu.MenuChangeEvent";
		redirects[events + "PauseCreationEvent"]			= events + "menu.pause.PauseCreationEvent";
		redirects[events + "WeekSelectEvent"]				= events + "menu.storymenu.WeekSelectEvent";
		redirects[events + "InputSystemEvent"]				= events + "note.InputSystemEvent";
		redirects[events + "NoteCreationEvent"]				= events + "note.NoteCreationEvent";
		redirects[events + "NoteHitEvent"]					= events + "note.NoteHitEvent";
		redirects[events + "NoteMissEvent"]					= events + "note.NoteMissEvent";
		redirects[events + "NoteUpdateEvent"]				= events + "note.NoteUpdateEvent";
		redirects[events + "SimpleNoteEvent"]				= events + "note.SimpleNoteEvent";
		redirects[events + "StrumCreationEvent"]			= events + "note.StrumCreationEvent";
		redirects[events + "SplashShowEvent"]				= events + "splash.SplashShowEvent";
		redirects[events + "PlayAnimContext"]				= events + "sprite.PlayAnimContext";
		redirects[events + "PlayAnimEvent"]					= events + "sprite.PlayAnimEvent";
		redirects[events + "StageNodeEvent"]				= events + "stage.StageNodeEvent";
		redirects[events + "StageXMLEvent"]					= events + "stage.StageXMLEvent";

		// Old State Names
		redirects["  codenamecrew.codenamecrew.funkin.menus.BetaWarningState"] 			= "  codenamecrew.codenamecrew.funkin.menus.WarningState";

		return redirects;
	}

	/**
	 * Gets the default defines for a script.
	 * Includes all of the defines that the build was compiled with.
	 */
	public static function getDefaultPreprocessors():Map<String, Dynamic> {
		var defines =   codenamecrew.codenamecrew.funkin.backend.system.macros.DefinesMacro.defines;
		defines.set("CODENAME_ENGINE", true);
		defines.set("CODENAME_VER", Flags.VERSION);
		defines.set("CODENAME_BUILD", 2675); // 2675 being the last build num before it was removed
		defines.set("CODENAME_COMMIT", Flags.COMMIT_NUMBER);
		return defines;
	}
	/**
	 * All available script extensions
	 */
	public static var scriptExtensions:Array<String> = [
		"hx", "hscript", "hsc", "hxs",
		"pack", // combined file
		"lua" /** ACTUALLY NOT SUPPORTED, ONLY FOR THE MESSAGE **/
	];

	/**
	 * Currently executing script.
	 */
	public static var curScript:Script = null;

	/**
	 * Shared empty argument array, used when calling scripts without parameters (avoids allocations).
	 */
	private static var _EMPTY_ARGS:Array<Dynamic> = [];

	/**
	 * Script name (with extension)
	 */
	public var fileName:String;

	/**
	 * Script Extension
	 */
	public var extension:String;

	/**
	 * Path to the script.
	 */
	public var path:String = null;

	private var rawPath:String = null;

	private var didLoad:Bool = false;

	/**
	 * Remapped filenames.
	 * Used for trace messages, to show what mod the script is from.
	 */
	public var remappedNames:Map<String, String> = [];

	/**
	 * Creates a script from the specified asset path. The language is automatically determined.
	 * @param path Path in assets
	 */
	public static function create(path:String):Script {
		if (Assets.exists(path)) {
			return switch(Path.extension(path).toLowerCase()) {
				case "hx" | "hscript" | "hsc" | "hxs":
					new HScript(path);
				case "pack":
					var arr = Assets.getText(path).split("________PACKSEP________");
					fromString(arr[1], arr[0]);
				case "lua":
					Logs.error("Lua is not supported in this engine. Use HScript instead.");
					new DummyScript(path);
				default:
					new DummyScript(path);
			}
		}
		return new DummyScript(path);
	}

	/**
	 * Creates a script from the string. The language is determined based on the path.
	 * @param code code
	 * @param path filename
	 */
	public static function fromString(code:String, path:String):Script {
		return switch(Path.extension(path).toLowerCase()) {
			case "hx" | "hscript" | "hsc" | "hxs":
				new HScript(path).loadFromString(code);
			case "lua":
				Logs.error("Lua is not supported in this engine. Use HScript instead.");
				new DummyScript(path).loadFromString(code);
			default:
				new DummyScript(path).loadFromString(code);
		}
	}

	/**
	 * Creates a new instance of the script class.
	 * @param path
	 */
	public function new(path:String) {
		super();

		rawPath = path;
		path = Paths.getFilenameFromLibFile(path);

		fileName = Path.withoutDirectory(path);
		extension = Path.extension(path);
		this.path = path;
		onCreate(path);
		for(k=>e in getDefaultVariables(this)) {
			set(k, e);
		}
		set("disableScript", () -> {
			active = false;
		});
		set("__script__", this);
	}


	/**
	 * Loads the script
	 */
	public function load() {
		if(didLoad) return;

		var oldScript = curScript;
		curScript = this;
		onLoad();
		curScript = oldScript;

		didLoad = true;
	}

	/**
	 * HSCRIPT ONLY FOR NOW
	 * Sets the "public" variables map for ScriptPack
	 */
	public function setPublicMap(map:Map<String, Dynamic>) {

	}

	/**
	 * Hot-reloads the script, if possible
	 */
	public function reload() {

	}

	/**
	 * Traces something as this script.
	 */
	public function trace(v:Dynamic) {
		var fileName = this.fileName;
		if(remappedNames.exists(fileName))
			fileName = remappedNames.get(fileName);
		Logs.traceColored([
			Logs.logText(fileName + ': ', GREEN),
			Logs.logText(Std.string(v))
		], TRACE);
	}


	/**
	 * Calls the function `func` defined in the script.
	 * @param func Name of the function
	 * @param parameters (Optional) Parameters of the function.
	 * @return Result (if void, then null)
	 */
	public function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
		var oldScript = curScript;
		curScript = this;

		var result = onCall(func, parameters);

		curScript = oldScript;
		return result;
	}

	/**
	 * Loads the code from a string, doesn't really work after the script has been loaded
	 * @param code The code.
	 */
	public function loadFromString(code:String) {
		return this;
	}

	/**
	 * Sets a script's parent object so that its properties can be accessed easily. Ex: Passing `PlayState.instance` will allow `boyfriend` to be typed instead of `PlayState.instance.boyfriend`.
	 * @param variable Parent variable.
	 */
	public function setParent(variable:Dynamic) {}

	/**
	 * Gets the variable `variable` from the script's variables.
	 * @param variable Name of the variable.
	 * @return Variable (or null if it doesn't exists)
	 */
	public function get(variable:String):Dynamic {return null;}

	/**
	 * Sets the variable `variable` from the script's variables.
	 * @param variable Name of the variable.
	 * @return Variable (or null if it doesn't exists)
	 */
	public function set(variable:String, value:Dynamic):Void {}

	/**
	 * Shows an error from this script.
	 * @param text Text of the error (ex: Null Object Reference).
	 * @param additionalInfo Additional information you could provide.
	 */
	public function error(text:String, ?additionalInfo:Dynamic):Void {
		var fileName = this.fileName;
		if(remappedNames.exists(fileName))
			fileName = remappedNames.get(fileName);
		Logs.traceColored([
			Logs.logText(fileName, RED),
			Logs.logText(text)
		], ERROR);
	}

	override public function toString():String {
		return FlxStringUtil.getDebugString(didLoad ? [
			LabelValuePair.weak("path", path),
			LabelValuePair.weak("active", active),
		] : [
			LabelValuePair.weak("path", path),
			LabelValuePair.weak("active", active),
			LabelValuePair.weak("loaded", didLoad),
		]);
	}

	/**
	 * PRIVATE HANDLERS - DO NOT TOUCH
	 */
	private function onCall(func:String, parameters:Array<Dynamic>):Dynamic {
		return null;
	}
	/**
	 * Called when the script is created.
	 * @param path Path to the script
	 */
	public function onCreate(path:String) {}

	/**
	 * Called when the script is loaded.
	 */
	public function onLoad() {}
}
