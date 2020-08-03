tool
extends Node

var innates:Dictionary = {}
var scripts:Dictionary = {"constants": [], "functions": []}
var symbols:Dictionary = {}
var layout:Dictionary = {}
var items:Dictionary = {
	"categories": [],
	"colors": [],
	"cast_backwards": [],
	"slots": {},
	"upgrade_modifier": {},
	"weaken_modified": {},
	"default_tags": {}
	}

func _init():
	load_data()

func load_data():
	var file = File.new()
	var path = "res://assets/api_%s/gamedata.json" % [ProjectSettings.get_setting("application/config/mod_api_version")]
	if file.open(path, File.READ) == OK:
		var json = parse_json(file.get_as_text())
		innates = json.innates
		scripts = json.scripts
		symbols = json.symbols
		layout = json.layout
		items = json.items
		file.close()
	else:
		printerr("Gamedata couldn't be loaded")
