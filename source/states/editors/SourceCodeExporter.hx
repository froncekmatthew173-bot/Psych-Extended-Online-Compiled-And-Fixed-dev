package states.editors;

import haxe.zip.Writer;
import haxe.zip.Entry;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import states.MainMenuState;
import online.gui.Alert;
import online.util.FileUtils;

class SourceCodeExporter {
	static inline var ZIP_NAME_PREFIX:String = "pexo-source";

	public static function export() {
		var cwd = Sys.getCwd();
		var sourceDir = Path.join([cwd, "source"]);
		var libDir = Path.join([cwd, "library_extended"]);
		var sourceDefaultDir = Path.join([cwd, "source_default"]);
		var sourceAngleDir = Path.join([cwd, "source_angle"]);

		if (!FileSystem.exists(sourceDir)) {
			Alert.alert("Source Export Failed", "Could not find source/ directory!");
			return;
		}

		Alert.alert("Exporting source code...", "Scanning source files...");

		var entryList:List<Entry> = new List();

		var rootFiles = ["Project.xml", "build-debug.hxml", "hmm.json"];
		for (f in rootFiles) {
			var fullPath = Path.join([cwd, f]);
			if (FileSystem.exists(fullPath) && !FileSystem.isDirectory(fullPath))
				addFile(entryList, f, fullPath);
		}

		scanAndAdd(entryList, sourceDir, "source");
		scanAndAdd(entryList, libDir, "library_extended");
		scanAndAdd(entryList, sourceDefaultDir, "source_default");
		scanAndAdd(entryList, sourceAngleDir, "source_angle");

		promptExternalDir(entryList);
	}

	static function promptExternalDir(entryList:List<Entry>) {
		Alert.alert("Optional: Add external folder", "Select a compiled build or mod folder, or cancel to skip.");

		var fileDialog = new FileDialog();
		fileDialog.onSelect.add(dirPath -> {
			if (FileSystem.exists(dirPath) && FileSystem.isDirectory(dirPath)) {
				var dirName = Path.withoutDirectory(dirPath);
				scanAndAddExternal(entryList, dirPath, "external/" + dirName);
				Alert.alert("Added: " + dirName, "Saved to ZIP as external/" + dirName + "/");
			}
			promptSave(entryList);
		});
		fileDialog.onCancel.add(() -> promptSave(entryList));
		fileDialog.browse(OPEN_DIRECTORY, null, Path.directory(Sys.getCwd()), Sys.getCwd());
	}

	static function promptSave(entryList:List<Entry>) {
		var fileCount = 0;
		for (_ in entryList)
			fileCount++;

		if (fileCount == 0) {
			Alert.alert("Export Failed", "No source files found!");
			return;
		}

		var version = MainMenuState.psychEngineVersion.trim();
		var zipFileName = '${ZIP_NAME_PREFIX}-v${version}.zip';

		var fileDialog = new FileDialog();
		fileDialog.onSelect.add(exportPath -> {
			try {
				var zipPath = Path.join([exportPath, zipFileName]);
				var output = new haxe.io.BytesOutput();
				var writer = new Writer(output);
				writer.write(entryList);
				File.saveBytes(zipPath, output.getBytes());
				Alert.alert("Export Complete!", 'Saved ${fileCount} files to:\n${zipFileName}');
			} catch (e:Dynamic) {
				Alert.alert("Export Error", 'Failed to save ZIP:\n${e}');
			}
		});
		fileDialog.browse(FileDialogType.SAVE, "zip", zipFileName, Sys.getCwd());
	}

	static function scanAndAdd(entryList:List<Entry>, basePath:String, zipPrefix:String) {
		if (!FileSystem.exists(basePath) || !FileSystem.isDirectory(basePath))
			return;

		FileUtils.forEachFile(basePath, (filePath) -> {
			var relativePath = filePath.replace("\\", "/");
			var idx = relativePath.indexOf(zipPrefix + "/");
			if (idx >= 0) {
				var zipPath = relativePath.substring(idx);
				addFile(entryList, zipPath, filePath);
			}
		});
	}

	static function scanAndAddExternal(entryList:List<Entry>, basePath:String, zipPrefix:String) {
		if (!FileSystem.exists(basePath) || !FileSystem.isDirectory(basePath))
			return;

		var dirName = Path.withoutDirectory(basePath);
		FileUtils.forEachFile(basePath, (filePath) -> {
			var relativePath = filePath.replace("\\", "/");
			var idx = relativePath.indexOf(dirName + "/");
			if (idx >= 0) {
				var zipPath = zipPrefix + "/" + relativePath.substring(idx + dirName.length + 1);
				addFile(entryList, zipPath, filePath);
			}
		});
	}

	static function addFile(entryList:List<Entry>, zipPath:String, fullPath:String) {
		try {
			var content = File.getBytes(fullPath);
			var entry:Entry = {
				fileName: zipPath,
				fileSize: content.length,
				fileTime: Date.now(),
				compressed: false,
				dataSize: content.length,
				data: content,
				crc32: null
			};
			entryList.add(entry);
		} catch (e:Dynamic) {
			trace('Failed to add to ZIP: ${fullPath} - ${e}');
		}
	}
}
