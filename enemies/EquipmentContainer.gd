extends HBoxContainer

signal value_changed(equipment, idx, value)

onready var Available = find_node("Available")
onready var Equipped = find_node("Equipped")
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
		
	Equipped.connect("value_changed", self, "_on_Equipped_value_changed")
	set_data({}, "")
	
func set_data(data, key):
	self.key = key
	self.data = data
	
	Available.clear()
	Equipped.clear()
	Description.text = ""
	
	var available = _equipment.keys()
	var equipped = data.get(self.key, [])
	
	var i = 0
	for key in equipped:
		Equipped.add_item(key)
		Equipped.set_item_metadata(i, key)
		i += 1
	
	i = 0
	for key in available:
		var desc = _equipment[key]
		Available.add_item(key)
		Available.set_item_metadata(i, key)
		i += 1
		
	Available.sort_items_by_text()
	Equipped.sort_items_by_text()

func _on_Available_item_selected(index):
	Equipped.unselect_all()
	var key = Available.get_item_metadata(index)
	Description.text = _equipment.get(key, "")

func _on_Equipped_item_selected(index):
	Available.unselect_all()
	var key = Equipped.get_item_metadata(index)
	Description.text = _equipment.get(key, "")
	
func _on_Equipped_value_changed(equipment, value):
	emit_signal("value_changed", equipment, value)
