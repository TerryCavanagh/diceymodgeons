extends PanelContainer

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
	
	_setup(BeforeCombat, "Script: Before Combat", "")
	_setup(AfterCombat, "Script: After Combat", "")
	_setup(BeforeStartTurn, "Script: Before Start Turn", "")
	_setup(OnStartTurn, "Script: On Start Turn", "")
	_setup(OnEndTurn, "Script: End Turn", "")
	
func _setup(node, key, def):
	node.text = data.get(key, def)
	_connect(node, key, "text_changed", "_on_EnemyScript_text_changed")
	
func _connect(node, key, _signal, _func):
	var param = [_signal, self, _func]
	if node.callv("is_connected", param):
		node.callv("disconnect", param)
	param.push_back([node, key])
	node.callv("connect", param)
	
func _on_EnemyScript_text_changed(text, node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, text)