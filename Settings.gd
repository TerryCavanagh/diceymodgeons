extends Node

const PATH = "user://settings.ini"

const DONT_SHOW_WARNINGS = "dont_show_warnings"
const GAME_PATH = "game_path"
const SYMBOLS_HASH = "symbols_img_hash"

var settings_file:ConfigFile = ConfigFile.new()

func _init():
	# if we can't load it we will try to save it
	if not settings_file.load(PATH):
		settings_file.save(PATH)

func set_value(key:String, value):
	settings_file.set_value("global", key, value)
	settings_file.save(PATH)

func get_value(key:String, default = null):
	return settings_file.get_value("global", key, default)

func set_symbols_hash(mod_id:String, value):
	settings_file.set_value(mod_id, SYMBOLS_HASH, value)
	settings_file.save(PATH)

func get_symbols_hash(mod_id:String):
	return settings_file.get_value(mod_id, SYMBOLS_HASH, {})
