extends PanelContainer

signal equipment_deleted(key)

onready var SizeOption = find_node("SizeOption")
onready var CategoryOption = find_node("CategoryOption")
onready var ColorOption = find_node("ColorOption")

onready var DeleteButton = find_node("DeleteButton")

onready var UsesSpin = find_node("UsesSpin")
onready var SpellSpin = find_node("SpellSpin")

onready var CastBackwardsCheck = find_node("CastBackwardsCheck")
onready var SingleUseCheck = find_node("SingleUseCheck")
onready var SpecialCheck = find_node("SpecialCheck")
onready var ErrorImmuneCheck = find_node("ErrorImmuneCheck")
onready var ShowGoldCheck = find_node("ShowGoldCheck")
onready var AppearForPartsCheck = find_node("AppearForPartsCheck")

onready var SlotsContainer = find_node("SlotsContainer")

onready var UpgradeOption = find_node("UpgradeOption")
onready var WeakenOption = find_node("WeakenOption")

onready var DescriptionEdit = find_node("DescriptionEdit")

onready var EquipmentCard = find_node("EquipmentCard")

var data_id:String = ""
var data:Dictionary = {}

func _ready():
	SizeOption.set_meta("list", ["1", "2"])
	
	Utils.fill_options(CategoryOption, Gamedata.items.get("categories", {}), true)
	Utils.fill_options(ColorOption, Gamedata.items.get("colors", []), true)
	Utils.fill_options(UpgradeOption, Gamedata.items.get("upgrade_modifier", {}), false)
	Utils.fill_options(WeakenOption, Gamedata.items.get("weaken_modifier", {}), false)
	
func set_data(data):
	data_id = data.get("Name", "")
	self.data = data
	
	_setup(SizeOption, "Size", 1)
	_setup(CategoryOption, "Category", "")
	_setup(ColorOption, "Colour", "")
	
	_setup(UsesSpin, "Uses?", 0)
	_setup(SpellSpin, "Witch Spell", 0)
	
	# TODO
	#_setup(CastBackwardsCheck, "Cast Backwards?", false)
	_setup(SingleUseCheck, "Single use?", false)
	_setup(SpecialCheck, "Special?", false)
	_setup(ErrorImmuneCheck, "Error Immune", false)
	_setup(ShowGoldCheck, "Show Gold", false)
	_setup(AppearForPartsCheck, "Appears For Parts", false)
	
	_setup(SlotsContainer, "Slots", [])
	
	_setup(UpgradeOption, "Upgrade", "")
	_setup(WeakenOption, "Weaken", "")
	
	_setup(DescriptionEdit, "Description", "")
	
	if data_id.find("_") > -1:
		var table = Database.get_table(Database.Table.EQUIPMENT)
		DeleteButton.visible = not table.is_in_game_data(data_id)
	
	EquipmentCard.set_title(data_id)
	EquipmentCard.change_size(data.get("Size", 1))
	EquipmentCard.set_description(data.get("Description", ""))
	
	EquipmentCard.change_color(data.get("Colour", ""), data.get("Category", ""), data_id.find("_upgraded") > -1)
	
func _setup(node, key, def):
	if node is SpinBox:
		node.value = data.get(key, def)
		Utils.connect_signal(node, key, "value_changed", self, "_on_SpinBox_value_changed")
	elif node is LineEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_LineEdit_text_changed")
	elif node is CheckBox:
		node.pressed = data.get(key, def)
		Utils.connect_signal(node, key, "toggled", self, "_on_CheckBox_toggled")
	elif node is TextEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")
	elif node is OptionButton:
		var s = str(data.get(key, def))
		Utils.option_select(node, s)
		Utils.connect_signal(node, key, "item_selected", self, "_on_OptionButton_item_selected")
	elif node == DescriptionEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")
	elif node == SlotsContainer:
		var category = data.get("Category", "")
		node.visible = not (category == "BACKUP" or category == "SKILLCARD")
		node.set_data(data)
		Utils.connect_signal(node, "Slots", "slots_changed", self, "_on_SlotsContainer_slots_changed")
		Utils.connect_signal(node, "NEED TOTAL?", "total_changed", self, "_on_SlotsContainer_total_changed")
	else:
		printerr("Node %s couldn't be setup" % node.name)
	
func _on_SpinBox_value_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, key, value)

func _on_LineEdit_text_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, key, value)
	
func _on_CheckBox_toggled(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, key, value)
	
func _on_TextEdit_text_changed(node, key):
	if not data_id: return
	
	if node == DescriptionEdit:
		EquipmentCard.set_description(node.text)
		
	Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, key, node.text)
	
func _on_OptionButton_item_selected(id, node, key):
	if not data_id: return
	Utils.update_option_tooltip(node, id)
	if node == ColorOption:
		var color = node.get_item_text(node.selected).to_upper()
		if node.selected == 0:
			color = ""
		EquipmentCard.change_color(color, Utils.option_get_selected_key(CategoryOption), data_id.find("_upgraded") > -1)
	if node == CategoryOption:
		if ColorOption.selected == 0:
			EquipmentCard.change_color("", Utils.option_get_selected_key(CategoryOption), data_id.find("_upgraded") > -1)
			
		var category = Utils.option_get_selected_key(CategoryOption)
		SlotsContainer.visible = not (category == "BACKUP" or category == "SKILLCARD")
		
	var value = Utils.option_get_selected_key(node)
	
	if (node == ColorOption or node == UpgradeOption or node == WeakenOption) and node.selected == 0:
		value = ""
		
	if node == SizeOption:
		value = node.selected + 1
		EquipmentCard.change_size(value)
		
	Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, key, value)
		
func _on_SlotsContainer_slots_changed(slots, node, key):
	if not data_id: return
	if node.visible:
		Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, key, slots)
	else:
		Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, key, [])

func _on_SlotsContainer_total_changed(new_total, node, key):
	if not data_id: return
	Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, key, new_total)

func _on_DeleteButton_pressed():
	if not data_id: return
	ConfirmPopup.popup_confirm("Are you sure you want to delete '%s'?" % data_id)
	var result = yield(ConfirmPopup, "action_chosen")
	if result == ConfirmPopup.OKAY:
		Database.commit(Database.Table.EQUIPMENT, Database.DELETE, data_id)
		emit_signal("equipment_deleted", data_id)
