package   codenamecrew.codenamecrew.funkin.backend.scripting.events.note;

import   codenamecrew.codenamecrew.funkin.game.Note;

final class SimpleNoteEvent extends CancellableEvent {
	/**
		Note that is affected.
	**/
	public var note:Note;
}