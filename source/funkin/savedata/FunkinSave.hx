package funkin.savedata;

import flixel.FlxG;
import haxe.ds.StringMap;

class FunkinSave {
	public static function getSongHighscore(song:String, diff:String):HighscoreEntry {
		var score:Int = 0;
		var misses:Int = 0;
		var accuracy:Float = 0;
		try {
			var key:String = song + "-" + diff;
			var savedScore = FlxG.save.data;
			if (Reflect.isObject(savedScore) && Reflect.hasField(savedScore, key)) {
				var data:Dynamic = Reflect.field(savedScore, key);
				if (data != null) {
					score = Reflect.hasField(data, "score") ? (Reflect.field(data, "score"):Int) : 0;
					misses = Reflect.hasField(data, "misses") ? (Reflect.field(data, "misses"):Int) : 0;
					accuracy = Reflect.hasField(data, "accuracy") ? Reflect.field(data, "accuracy") : 0;
				}
			}
		} catch (e:Dynamic) {}
		return new HighscoreEntry(score, misses, accuracy);
	}

	public static function flush() {
		FlxG.save.flush();
	}
}
