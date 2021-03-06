extends HBoxContainer

signal value_changed(equipment, idx, value)

export (bool) var order_equipped = true setget _set_order_equipped
export (bool) var show_only_special = false setget _set_show_only_special

onready var AvailableContainer = find_node("AvailableContainer")
onready var EquippedContainer = find_node("EquippedContainer")
onready var EquipmentCard = find_node("EquipmentCard")

var key:String
var data:Dictionary = {}
var _equipment:Array = []

var filter_list_func:FuncRef = null
var append_equipment_func:FuncRef = null

var _special_tag = "skillcard"

func _ready():
	set_data({}, "")
	EquippedContainer.order = order_equipped

func _load_equipment_list():
	var equipment = Database.commit(Database.Table.EQUIPMENT, Database.READ)
	if not equipment: return false
	_equipment = []
	for key in equipment.keys():
		var e = equipment.get(key)
		var special = _special_tag in e.get("Tags", [])
		if show_only_special:
			if not special:
				continue
		elif special:
			continue
		if filter_list_func and not filter_list_func.call_func(e):
			continue

		var category = e.get("Category", "ITEM")

		_equipment.push_back({"prepared": false, "equipment": key, "category": category})

	if show_only_special:
		_equipment.push_back({"prepared": false, "equipment": "Monstermode"})

	if append_equipment_func:
		append_equipment_func.call_func(_equipment)

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
	for equip in equipped:
		equip["equipment"] = Utils.to_csv_equipment_name(equip["equipment"])

	AvailableContainer.set_list(available)
	EquippedContainer.set_list(equipped)

func _update_card(equipment):
	if not equipment: return
	var key = equipment.get("equipment", "")
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

func _set_show_only_special(v):
	show_only_special = v
	if not EquippedContainer: return
	set_data(data, key)
