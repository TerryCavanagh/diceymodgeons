tool
extends Node

var innates:Dictionary = {}
var scripts:Dictionary = {"constants": [], "functions": []}
var symbols:Dictionary = {}
var items:Dictionary = {
	"categories": [],
	"colors": [],
	"cast_backwards": [],
	"slots": {},
	"upgrade_modifier": {},
	"weaken_modified": {}
	}

func _init():
	load_data()
	
func load_data():
	var file = File.new()
	if file.open("res://test/data/text/gamedata.json", File.READ) == OK:
		var json = parse_json(file.get_as_text())
		innates = json.innates
		scripts = json.scripts
		symbols = json.symbols
		items = json.items
		file.close()
	else:
		printerr("Gamedata couldn't be loaded")