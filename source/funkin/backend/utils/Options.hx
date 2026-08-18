package funkin.backend.utils;

import backend.ClientPrefs;

class Options {
	public static var gameplayShaders(get, never):Bool;
	public static var colorHealthBar(get, never):Bool;

	static function get_gameplayShaders():Bool return ClientPrefs.data.shaders;
	static function get_colorHealthBar():Bool return false;
}
