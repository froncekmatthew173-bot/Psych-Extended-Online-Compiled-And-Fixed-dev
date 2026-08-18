package funkin.backend.scripting;

#if SCRIPTING_ALLOWED
class ModState extends MusicBeatState {

	/**
	* Name of HScript file in assets/data/states.
	*/
	public static var lastName:String = null;
	/**
	* Last Optional extra data.
	*/
	public static var lastData:Dynamic = null;

	/**
	* Optional extra data.
	*/
	public var data:Dynamic = null;

	/**
	* The mod directory that was active when this ModState was created.
	* Used to restore the mod context for script loading.
	*/
	public var savedModDir:String = null;

	/**
	* ModState Constructor.
	* Inherits from MusicBeatState and allows the execution of an HScript from assets/data/states passed via parameters.
	*
	* @param _stateName Name or path to a HScript file from assets/data/states.
	* @param _data Optional extra Dynamic data passed from a previous state (JSON suggested).
	*/
	public function new(_stateName:String, ?_data:Dynamic) {
		if(_stateName != null && _stateName != lastName) {
			lastName = _stateName;
			lastData = null;
		}

		if(_data != null)
			lastData = _data;

		data = lastData;
		#if MODS_ALLOWED
		savedModDir = Mods.currentModDirectory;
		#end
		super(true, lastName);
	}

	override public function create() {
		#if MODS_ALLOWED
		if (savedModDir != null)
			Mods.currentModDirectory = savedModDir;
		#end
		super.create();
	}
}
#end