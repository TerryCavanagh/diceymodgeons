extends Node

var innates:Dictionary = {}
var scripts:Dictionary = {"constants": [], "functions": []}

func _init():
	load_data()
	
func load_data():
	var file = File.new()
	if file.open("res://data/text/gamedata.json", File.READ) == OK:
		var json = parse_json(file.get_as_text())
		innates = json.innates
		scripts = json.scripts
		file.close()
	else:
		printerr("Gamedata couldn't be loaded")