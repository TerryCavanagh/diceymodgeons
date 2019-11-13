extends PanelContainer

onready var StartGame = find_node("Start Game")
onready var StartCombat = find_node("Start Combat")
onready var BeforeStartTurn = find_node("Before Start Turn")
onready var OnStartTurn = find_node("On Start Turn")
onready var EndTurn = find_node("End Turn")
onready var AfterCombat = find_node("After Combat")
onready var AfterLevelUp = find_node("After Level Up")
onready var LevelUpRewards = find_node("Level Up Rewards")
onready var ChangeFloor = find_node("Change Floor")

var data_id:String = ""
var data:Dictionary = {}

func set_data(data):
	data_id = Database.mixed_key(["Character", "Level"], data)
	self.data = data
	
	_setup(StartGame, "Start Game", "Script: Start Game", "")
	_setup(StartCombat, "Start Combat", "Script: Start Combat", "")
	_setup(BeforeStartTurn, "Before Start Turn", "Script: Before Start Turn", "")
	_setup(OnStartTurn, "On Start Turn", "Script: On Start Turn", "")
	_setup(EndTurn, "End Turn", "Script: End Turn", "")
	_setup(AfterCombat, "After Combat", "Script: After Combat", "")
	_setup(AfterLevelUp, "After Level Up", "Script: After Level Up", "")
	_setup(LevelUpRewards, "Level Up Rewards", "Script: Define Level Up Rewards", "")
	_setup(ChangeFloor, "Change Floor", "Script: Change Floor", "")
	
func _setup(node:Node, node_name, key, def):
	node.text = data.get(key, def)
	node.set_meta("original_name", node_name)
	_change_name(node, node.text.empty())
	Utils.connect_signal(node, key, "text_changed", self, "_on_Script_text_changed")
	
func _change_name(node, empty_text):
	if empty_text:
		node.name = node.get_meta("original_name")
	else:
		node.name = "[%s]" % node.get_meta("original_name")
	
func _on_Script_text_changed(text, node, key):
	if not data_id: return
	_change_name(node, text.empty())
	Database.commit(Database.Table.EPISODES, Database.UPDATE, data_id, key, text)
