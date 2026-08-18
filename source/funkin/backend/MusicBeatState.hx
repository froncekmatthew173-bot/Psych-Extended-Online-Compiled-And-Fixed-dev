package funkin.backend;

import backend.MusicBeatState as PSYMusicBeatState;

/**
 * CNE-compatible MusicBeatState. Extends the Psych Engine MusicBeatState
 * but adds CNE-style static properties for transition controls.
 */
class MusicBeatState extends PSYMusicBeatState {
	public static var skipTransIn:Bool = false;
	public static var skipTransOut:Bool = false;
}
