extends PanelContainer

onready var NameEdit = find_node("NameEdit")
onready var LevelBox = find_node("LevelBox")
onready var HealthBox = find_node("HealthBox")
onready var DiceBox = find_node("DiceBox")
onready var AIEdit = find_node("AIEdit")
onready var VoiceEdit = find_node("VoiceEdit")
onready var ChatVoiceEdit = find_node("ChatVoiceEdit")
onready var SuperCheck = find_node("SuperCheck")
onready var RareCheck = find_node("RareCheck")
onready var BossCheck = find_node("BossCheck")
onready var SuperRow = find_node("SuperRow")
onready var SuperHealthBox = find_node("SuperHealthBox")
onready var SuperDiceBox = find_node("SuperDiceBox")
onready var FirstWordsEdit = find_node("FirstWordsEdit")
onready var LastWordsEdit = find_node("LastWordsEdit")

onready var InnateContainer = find_node("InnateContainer")
onready var EquipmentContainer = find_node("EquipmentContainer")
onready var SuperEquipmentContainer = find_node("SuperEquipmentContainer")

var data_id:String = ""
var data:Dictionary = {}

func _ready():
	SuperCheck.connect("toggled", self, "_show_super_row")
	
func set_data(data):
	data_id = data.get("Name", "")
	self.data = data
	
	_setup(LevelBox, "Level", 0)
	_setup(HealthBox, "Health", 0)
	_setup(DiceBox, "Dice", 0)
	_setup(AIEdit, "AI", "")
	_setup(VoiceEdit, "Voice", "")
	_setup(ChatVoiceEdit, "Chat Voice", "")
	_setup(SuperCheck, "Super?", false)
	_setup(RareCheck, "Rare?", false)
	_setup(BossCheck, "Boss?", false)
	_setup(SuperHealthBox, "Super Health", 0)
	_setup(SuperDiceBox, "Super Dice", 0)
	_setup(FirstWordsEdit, "First Words", "")
	_setup(LastWordsEdit, "Last Words", "")
	
	_setup(InnateContainer, "Innate", [])
	_setup(EquipmentContainer, "Equipment", [])
	_setup(SuperEquipmentContainer, "Super Equipment", [])
	
	_show_super_row(SuperCheck.pressed)
	
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
	elif node == InnateContainer:
		node.set_data(data)
		Utils.connect_signal(node, key, "value_changed", self, "_on_InnateContainer_value_changed")
	elif node == EquipmentContainer or node == SuperEquipmentContainer:
		node.set_data(data, key)
		Utils.connect_signal(node, key, "value_changed", self, "_on_EquipmentContainer_value_changed")
	else:
		printerr("Node %s couldn't be setup" % node.name)
	
func _on_SpinBox_value_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, value)
	
func _on_LineEdit_text_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, value)
	
func _on_CheckBox_toggled(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, value)
	
func _on_TextEdit_text_changed(node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, node.text)
	
func _on_InnateContainer_value_changed(innate, value, node, key):
	if not data_id: return
	var action = Database.CREATE if value else Database.DELETE
	Database.commit(Database.Table.FIGHTERS, action, data_id, key, innate)
	
func _on_EquipmentContainer_value_changed(equipment, value, node, key):
	if not data_id: return
	var action = Database.CREATE if value else Database.DELETE
	Database.commit(Database.Table.FIGHTERS, action, data_id, key, equipment)
	
func _show_super_row(value):
	SuperRow.visible = value