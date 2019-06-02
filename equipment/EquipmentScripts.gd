extends PanelContainer


onready var TabContainer = find_node("TabContainer")

onready var OnExecute = find_node("On Execute")
onready var BeforeCombat = find_node("Before Combat")
onready var AfterCombat = find_node("After Combat")
onready var BeforeStartTurn = find_node("Before Start Turn")
onready var OnStartTurn = find_node("On Start Turn")
onready var OnEndTurn = find_node("On End Turn")

var data_id:String = ""
var data:Dictionary = {}

func _ready():
	pass
	
func set_data(data):
	self.data = data
	self.data_id = data["Name"]
	
	_setup(OnExecute, "On Execute", "Script: On Execute", "")
	_setup(BeforeCombat, "Before Combat", "Script: Before Combat", "")
	_setup(AfterCombat, "After Combat", "Script: After Combat", "")
	_setup(BeforeStartTurn, "Before Start Turn", "Script: Before Start Turn", "")
	_setup(OnStartTurn, "On Start Turn", "Script: On Start Turn", "")
	_setup(OnEndTurn, "On End Turn", "Script: End Turn", "")
	
func _setup(node, node_name, key, def):
	node.text = data.get(key, def)
	var idx = node.get_position_in_parent()
	# TODO This is broken in godot right now so wait for fix
	#TabContainer.set_tab_title(idx, node_name)
	_connect(node, key, "text_changed", "_on_Script_text_changed")
	
func _connect(node, key, _signal, _func):
	var param = [_signal, self, _func]
	if node.callv("is_connected", param):
		node.callv("disconnect", param)
	param.push_back([node, key])
	node.callv("connect", param)
	
func _on_Script_text_changed(text, node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, text)