extends HBoxContainer

signal value_changed(equipment, idx, value)

onready var AvailableContainer = find_node("AvailableContainer")
onready var EquippedContainer = find_node("EquippedContainer")
onready var EquipmentCard = find_node("EquipmentCard")

var key:String
var data:Dictionary = {}
var _equipment:Array = []

func _ready():
	set_data({}, "")
	
func _load_equipment_list():
	var equipment = Database.commit(Database.Table.EQUIPMENT, Database.READ)
	if not equipment: return false
	# TODO what about the ones ending in ? or having a @
	for key in equipment.keys():
		if key.find("_") > -1 or key.find("?") > -1: continue
		_equipment.push_back(key)
	
	return true
	
func set_data(data, key):
	self.key = key
	self.data = data
	
	EquipmentCard.visible = false
	
	if not _load_equipment_list(): return
	
	var available = _equipment
	var equipped = data.get(self.key, [])
	
	AvailableContainer.set_list(available)
	EquippedContainer.set_list(equipped)
	
func _update_card(key):
	EquipmentCard.visible = true
	var equip = Database.commit(Database.Table.EQUIPMENT, Database.READ, key)
	EquipmentCard.set_title(equip.get("Name", "Title"))
	EquipmentCard.change_size(equip.get("Size", 1))
	EquipmentCard.change_color(equip.get("Colour", "GRAY"))
	EquipmentCard.set_description(equip.get("Description", ""))

func _on_AvailableContainer_item_selected(equipment):
	EquippedContainer.unselect_all()
	_update_card(equipment)


func _on_EquippedContainer_item_selected(equipment):
	AvailableContainer.unselect_all()
	_update_card(equipment)

func _on_EquippedContainer_value_changed(equipment, value):
	emit_signal("value_changed", equipment, value)
