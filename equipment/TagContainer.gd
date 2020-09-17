extends HBoxContainer

signal delete_requested()

onready var TagLabel = find_node("TagLabel")
onready var DeleteButton = find_node("DeleteButton")

var tag:String = ""
var tooltip:String = ""

func _ready():
	TagLabel.text = tag
	hint_tooltip = tooltip

func set_tag(tag, tooltip):
	self.tag = tag
	self.tooltip = tooltip


func _on_DeleteButton_pressed():
	emit_signal("delete_requested")
