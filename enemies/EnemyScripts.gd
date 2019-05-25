extends PanelContainer

onready var BeforeCombat = find_node("Before Combat")
onready var AfterCombat = find_node("After Combat")
onready var BeforeStartTurn = find_node("Before Start Turn")
onready var OnStartTurn = find_node("On Start Turn")
onready var OnEndTurn = find_node("On End Turn")

var data:Dictionary

func _ready():
	pass
	
func set_data(data):
	self.data = data
	
	BeforeCombat.text = data.get("Script: Before Combat", "")
	AfterCombat.text = data.get("Script: After Combat", "")
	BeforeStartTurn.text = data.get("Script: Before Start Turn", "")
	OnStartTurn.text = data.get("Script: On Start Turn", "")
	OnEndTurn.text = data.get("Script: End Turn", "")