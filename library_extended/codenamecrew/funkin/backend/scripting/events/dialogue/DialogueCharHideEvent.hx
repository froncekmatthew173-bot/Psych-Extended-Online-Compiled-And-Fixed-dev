package   codenamecrew.codenamecrew.funkin.backend.scripting.events.dialogue;

import   codenamecrew.codenamecrew.funkin.game.cutscenes.dialogue.DialogueCharacter.DialogueCharAnimContext;

final class DialogueCharHideEvent extends CancellableEvent
{
	public var animation:String;

	public var lastAnimContext:DialogueCharAnimContext;
}