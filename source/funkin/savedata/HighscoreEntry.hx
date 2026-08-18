package funkin.savedata;

class HighscoreEntry {
	public var score:Int;
	public var misses:Int;
	public var accuracy:Float;

	public function new(score:Int = 0, misses:Int = 0, accuracy:Float = 0) {
		this.score = score;
		this.misses = misses;
		this.accuracy = accuracy;
	}
}
