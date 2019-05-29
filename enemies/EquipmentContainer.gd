extends HBoxContainer

signal value_changed(equipment, idx, value)

onready var AvailableContainer = find_node("AvailableContainer")
onready var EquippedContainer = find_node("EquippedContainer")
onready var Description = find_node("Description")

var key:String
var data:Dictionary = {}
var _equipment:Dictionary = {}

func _ready():
	var equipment = Database.commit(Database.Table.EQUIPMENT, Database.READ)
	# TODO what about the ones ending in ? or having a @
	for key in equipment.keys():
		if key.find("_") > -1 or key.find("?") > -1: continue
		var equip = equipment[key]
		_equipment[key] = equip.get("Description", "")
	set_data({}, "")
	
func set_data(data, key):
	self.key = key
	self.data = data
	
	Description.text = ""
	
	var available = _equipment.keys()
	var equipped = data.get(self.key, [])
	
	AvailableContainer.set_list(available)
	EquippedContainer.set_list(equipped)
	

func _on_AvailableContainer_item_selected(equipment):
	EquippedContainer.unselect_all()
	Description.text = _equipment.get(equipment, "")


func _on_EquippedContainer_item_selected(equipment):
	AvailableContainer.unselect_all()
	Description.text = _equipment.get(equipment, "")

func _on_EquippedContainer_value_changed(equipment, value):
	emit_signal("value_changed", equipment, value)
