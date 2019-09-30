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
	
	_setup(StartGame, "Script: Start Game", "")
	_setup(StartCombat, "Script: Start Combat", "")
	_setup(BeforeStartTurn, "Script: Before Start Turn", "")
	_setup(OnStartTurn, "Script: On Start Turn", "")
	_setup(EndTurn, "Script: End Turn", "")
	_setup(AfterCombat, "Script: After Combat", "")
	_setup(AfterLevelUp, "Script: After Level Up", "")
	_setup(LevelUpRewards, "Script: Define Level Up Rewards", "")
	_setup(ChangeFloor, "Script: Change Floor", "")
	
func _setup(node:Node, key, def):
	node.text = data.get(key, def)
	Utils.connect_signal(node, key, "text_changed", self, "_on_Script_text_changed")
	
func _on_Script_text_changed(text, node, key):
	if not data_id: return
	Database.commit(Database.Table.EPISODES, Database.UPDATE, data_id, key, text)
