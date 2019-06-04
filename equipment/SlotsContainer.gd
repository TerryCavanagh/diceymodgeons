extends PanelContainer

onready var SlotsNumberSpin = find_node("SlotsNumberSpin")

onready var Slot1Option = find_node("Slot1Option")
onready var Slot2Option = find_node("Slot2Option")
onready var Slot3Option = find_node("Slot3Option")
onready var Slot4Option = find_node("Slot4Option")

onready var ExtraContainer = find_node("ExtraContainer")
onready var ExtraSpin = find_node("ExtraSpin")

onready var ErrorLabel = find_node("ErrorLabel")

var data_id:String = ""
var data:Dictionary = {}


func _ready():
	var dict = Gamedata.items.get("slots", {})
	Utils.fill_options(Slot1Option, dict)
	Utils.fill_options(Slot2Option, dict)
	Utils.fill_options(Slot3Option, dict)
	Utils.fill_options(Slot4Option, dict)
	
func set_data(data):
	self.data_id = data.get("Name", "")
	self.data = data
	
	