extends HBoxContainer

signal value_changed(equipment, idx, value)

export (bool) var order_equipped = true setget _set_order_equipped

onready var AvailableContainer = find_node("AvailableContainer")
onready var EquippedContainer = find_node("EquippedContainer")
onready var EquipmentCard = find_node("EquipmentCard")

var key:String
var data:Dictionary = {}
var _equipment:Array = []

var filter_list_func:FuncRef = null

func _ready():
	set_data({}, "")
	EquippedContainer.order = order_equipped
	
func _load_equipment_list():
	var equipment = Database.commit(Database.Table.EQUIPMENT, Database.READ)
	if not equipment: return false
	_equipment = []
	for key in equipment.keys():
		var e = equipment.get(key)
		# don't show special equipment
		if e.get("Special?", false): continue
		if filter_list_func and not filter_list_func.call_func(e): 
			continue
			
		_equipment.push_back(key)
	
	return true
	
func force_reload():
	set_data(data, key)
	
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
	var equip = Database.commit(Database.Table.EQUIPMENT, Database.READ, key)
	if not equip:
		EquipmentCard.visible = false
		return
		
	EquipmentCard.visible = true
	EquipmentCard.set_title(equip.get("Name", "Title"))
	EquipmentCard.change_size(equip.get("Size", 1))
	EquipmentCard.change_color(equip.get("Colour", "GRAY"), equip.get("Category", ""))
	EquipmentCard.set_description(equip.get("Description", ""))

func _on_AvailableContainer_item_selected(equipment):
	EquippedContainer.unselect_all()
	_update_card(equipment)

func _on_EquippedContainer_item_selected(equipment):
	AvailableContainer.unselect_all()
	_update_card(equipment)

func _on_EquippedContainer_value_changed(equipment, value):
	emit_signal("value_changed", equipment, value)
	
func _set_order_equipped(v):
	order_equipped = v
	if not EquippedContainer: return
	EquippedContainer.order = order_equipped
