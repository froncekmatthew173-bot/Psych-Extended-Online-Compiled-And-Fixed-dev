package   codenamecrew.codenamecrew.funkin.options.categories;

import   codenamecrew.codenamecrew.funkin.savedata.codenamecrew.funkin.Save;

class MiscOptions extends TreeMenuScreen {
	public function new() {
		super('optionsTree.miscellaneous-name', 'optionsTree.miscellaneous-desc', 'MiscOptions.');

		add(new Checkbox(getNameID('devMode'), getDescID('devMode'), 'devMode'));
		add(new Checkbox(getNameID('allowConfigWarning'), getDescID('allowConfigWarning'), 'allowConfigWarning'));
		#if UPDATE_CHECKING
		add(new Checkbox(getNameID('betaUpdates'), getDescID('betaUpdates'), 'betaUpdates'));
		add(new TextOption(getNameID('checkForUpdates'), getDescID('checkForUpdates'), () -> {
			var report =   codenamecrew.codenamecrew.funkin.backend.system.updating.UpdateUtil.checkForUpdates(true);
			if (report.newUpdate) FlxG.switchState(new   codenamecrew.codenamecrew.funkin.backend.system.updating.UpdateAvailableScreen(report));
			else {
				CoolUtil.playMenuSFX(CANCEL);
				//updateDescText(translate('checkForUpdates-noUpdateFound'));
			}
		}));
		#end

		add(new Separator());
		add(new TextOption(getNameID('resetSaveData'), getDescID('resetSaveData'), () -> {
			codenamecrew.funkin.Save.save.erase();
			codenamecrew.funkin.Save.highscores.clear();
			codenamecrew.funkin.Save.flush();
		}));
	}
}