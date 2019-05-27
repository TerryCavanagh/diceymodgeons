extends VBoxContainer

signal value_changed(innate, value)

onready var Innates = find_node("Innates")

var data:Dictionary = {}

func _ready():
	for innate in Gamedata.innates.keys():
		var check = CheckBox.new()
		check.text = Gamedata.innates[innate].capitalize()
		check.hint_tooltip = innate
		check.set_meta("innate", innate)
		check.connect("pressed", self, "_on_checkbox_pressed", [innate, check])
		Innates.add_child(check)
		
func set_data(data):
	self.data = data
	
	var innates = data.get("Innate", [])
	for check in Innates.get_children():
		check.pressed = innates.has(check.get_meta("innate"))
		
func _on_checkbox_pressed(innate, check):
	emit_signal("value_changed", innate, check.pressed)
