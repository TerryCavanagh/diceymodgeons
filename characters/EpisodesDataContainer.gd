extends PanelContainer

onready var NameEdit = find_node("NameEdit")
onready var DiceSpin = find_node("DiceSpin")
onready var HealthSpin = find_node("HealthSpin")

onready var LayoutOption = find_node("LayoutOption")
onready var LimitOption = find_node("LimitOption")
onready var WeakenedLimitOption = find_node("WeakenedLimitOption")

onready var SuperEnemy2Spin = find_node("SuperEnemy2Spin")
onready var SuperEnemy3Spin = find_node("SuperEnemy3Spin")
onready var SuperEnemy4Spin = find_node("SuperEnemy4Spin")
onready var SuperEnemy5Spin = find_node("SuperEnemy5Spin")

onready var DescriptionEdit = find_node("DescriptionEdit")
onready var RulesDescriptionEdit = find_node("RulesDescriptionEdit")

onready var EquipmentContainer = find_node("EquipmentContainer")
onready var SkillcardContainer = find_node("SkillcardContainer")

var data_id:String = ""
var data:Dictionary = {}

func set_data(data):
	data_id = Database.mixed_key(["Character", "Level"], data)
	self.data = data

	_setup(NameEdit, "Episode Name", "")
	_setup(DiceSpin, "Dice", 0)
	_setup(HealthSpin, "Health", 1)
	
	Utils.fill_options(LayoutOption, Gamedata.layout, true)
	
	var items = Database.commit(Database.Table.ITEMS, Database.READ, null, "Name")
	
	Utils.fill_options(LimitOption, items, false)
	Utils.fill_options(WeakenedLimitOption, items, false)
	
	_setup(LayoutOption, "Layout", "EQUIPMENT")
	_setup(LimitOption, "Limit", "Fury")
	_setup(WeakenedLimitOption, "Weakened Limit", "Tantrum")
	
	_setup(SuperEnemy2Spin, "Super Level 2", 0)
	_setup(SuperEnemy3Spin, "Super Level 3", 0)
	_setup(SuperEnemy4Spin, "Super Level 4", 0)
	_setup(SuperEnemy5Spin, "Super Level 5", 0)
	
	_setup(DescriptionEdit, "Description", "")
	_setup(RulesDescriptionEdit, "Rules Description", "")
	
	#_setup(EquipmentContainer, "Equipment", [])
	_setup(SkillcardContainer, "Skillcard", [])
	

func _setup(node:Node, key, def):
	if node is SpinBox:
		node.value = data.get(key, def)
		Utils.connect_signal(node, key, "value_changed", self, "_on_SpinBox_value_changed")
	elif node is LineEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_LineEdit_text_changed")
	elif node is TextEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")
	elif node is OptionButton:
		var s = str(data.get(key, def))
		Utils.option_select(node, s)
		Utils.connect_signal(node, key, "item_selected", self, "_on_OptionButton_item_selected")
	elif node == EquipmentContainer or node == SkillcardContainer:
		node.set_data(data, key)
		Utils.connect_signal(node, key, "value_changed", self, "_on_EquipmentContainer_value_changed")
		
func _on_SpinBox_value_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.EPISODES, Database.UPDATE, data_id, key, value)

func _on_LineEdit_text_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.EPISODES, Database.UPDATE, data_id, key, value)
	
func _on_CheckBox_toggled(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.EPISODES, Database.UPDATE, data_id, key, value)
	
func _on_TextEdit_text_changed(node, key):
	if not data_id: return
	Database.commit(Database.Table.EPISODES, Database.UPDATE, data_id, key, node.text)
	
func _on_OptionButton_item_selected(id, node, key):
	if not data_id: return
	Utils.update_option_tooltip(node, id)
	var value = Utils.option_get_selected_key(node)
	Database.commit(Database.Table.EPISODES, Database.UPDATE, data_id, key, value)
	
func _on_EquipmentContainer_value_changed(equipment, value, node, key):
	if not data_id: return
	var action = Database.CREATE if value else Database.DELETE
	Database.commit(Database.Table.EPISODES, action, data_id, key, equipment)
