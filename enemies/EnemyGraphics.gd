extends PanelContainer

var data_id:String = ""
var data:Dictionary = {}

onready var CombatScreen = find_node("CombatScreen")

func _ready():
	CombatScreen.connect("image_changed", self, "_on_CombatScreen_image_changed")
	CombatScreen.connect("position_changed", self, "_on_CombatScreen_position_changed")

func set_data(data):
	self.data = data
	data_id = Database.get_data_id(data, "ID")

	var sprite_name = data.get("CombatAnimation", null)
	var sprite_offset = data.get("CombatAnimationOffset", Vector2())
	var overworld_name = data.get("OverworldAnimation", null)
	var overworld_offset = data.get("OverworldAnimationOffset", Vector2())

	CombatScreen.reset()

	if sprite_name:
		print(sprite_name)
		# TODO
		var texture = null
		var hd = false
		CombatScreen.set_sprite(texture, sprite_offset, hd)

	if overworld_name:
		print(overworld_name)
		# TODO
		var texture = null
		var hd = false
		CombatScreen.set_overworld_sprite(texture, overworld_offset, hd)

func _on_CombatScreen_image_changed(image, path, target):
	pass # Replace with function body.

func _on_CombatScreen_position_changed(new_position, target):
	print(target, " => ", new_position)
