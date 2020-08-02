extends Node

enum Origin {
	GAME,
	MOD
}

var game_root_path = ""
var mod_root_path = ""

var loaded_files:Dictionary = {}

func _init():
	game_root_path = "res://test"
	mod_root_path = "mods/garfield"

func get_mod_path(file_path:String = ""):
	return '%s/%s/%s' % [game_root_path, mod_root_path, file_path]

func get_game_path(file_path:String = ""):
	var extra_path = ""
	if OS.get_name() == "OSX":
		extra_path = "diceydungeons.app/Contents/Resources"
	return '%s/%s/%s' % [game_root_path, extra_path, file_path]

func is_file_opened(path:String):
	return path in loaded_files

func close_file(path:String):
	if path in loaded_files:
		loaded_files.erase(path)

func get_file_as_text(file_path:String)->ScriptFile:
	var file = _get_file(file_path)
	if file:
		var result = file.file.get_as_text()
		file.file.close()
		var r = ScriptFile.new()
		r.text = result
		r.changed_text = result
		r.path = file.path
		r.origin = file.origin
		loaded_files[file.path] = r
		return r

	return null

func get_file_csv(file_path:String)->CsvFile:
	var file = _get_file(file_path)
	if file:
			var headers = Array(file.file.get_csv_line())
			var content = []
			while not file.file.eof_reached():
				var values = Array(file.file.get_csv_line())
				values.resize(headers.size())
				content.push_back(values)

			file.file.close()

			var r = CsvFile.new()
			r.headers = headers
			r.csv = content
			r.original_hash = content.hash()
			r.path = file.path
			r.origin = file.origin
			loaded_files[file.path] = r
			return r

	return null

func file_needs_save(path:String):
	var file = loaded_files.get(path, null)
	if file:
		return _file_needs_save(file)
	return false

func files_need_save():
	for key in loaded_files:
		var file = loaded_files[key]
		if _file_needs_save(file):
			return true
	return false

func save_files():
	for key in loaded_files:
		save_file(key)

func save_file(file_path):
	if not file_path in loaded_files: return

	var obj = loaded_files[file_path]

	if not _file_needs_save(obj): return

	var path = obj.path
	if obj.origin == Origin.GAME:
		var fname = path.get_file()
		path = get_mod_path("data/text/generators/%s" % fname)

	if obj is CsvFile:
		var file = File.new()
		if file.open(path, File.WRITE) == OK:
			file.store_csv_line(obj.headers)

		var headers_size = obj.headers.size()
		for line in obj.csv:
			var empty = 0
			for i in headers_size:
				var c = line[i]
				if not c or c.empty():
					empty += 1

			if empty < headers_size:
				file.store_csv_line(line)

		file.close()
		obj.original_hash = obj.csv.hash()
	elif obj is ScriptFile:
		var file = File.new()
		if file.open(path, File.WRITE) == OK:
			file.store_string(obj.changed_text)
			file.close()
			obj.text = obj.changed_text

func _file_needs_save(file):
	if file is CsvFile:
		return file.csv.hash() != file.original_hash
	elif file is ScriptFile:
		return file.text.hash() != file.changed_text.hash()

func _get_file(file_path:String):
	var mod_path = get_mod_path(file_path)
	var game_path = get_game_path(file_path)

	var file := File.new()
	if file.open(mod_path, File.READ) == OK:
		return {"file": file, "path": mod_path, "origin": Origin.MOD}
	elif file.open(game_path, File.READ) == OK:
		return {"file": file, "path": game_path, "origin": Origin.GAME}

	return null


class ScriptFile extends Resource:
	var text:String = ""
	var changed_text:String = ""
	var path:String = ""
	var origin = Origin.MOD

class CsvFile extends Resource:
	var headers:Array = []
	var csv:Array = []
	var original_hash:int = -1
	var path:String = ""
	var origin = Origin.MOD
