package funkin.backend.utils;

class CoolUtil {
	public static function fpsLerp(v1:Float, v2:Float, ratio:Float):Float {
		return v1 + (v2 - v1) * Math.min(ratio, 1.0);
	}

	public static function coolTextFile(path:String):Array<String> {
		return backend.CoolUtil.coolTextFile(path);
	}
}
