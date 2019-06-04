extends HBoxContainer

signal text_changed()

onready var TextEdit = find_node("TextEdit")
onready var Symbols = find_node("Symbols")

var text = "" setget _set_text, _get_text

func _ready():
	TextEdit.text = text

func _set_text(value):
	text = value
	if not TextEdit: return
	TextEdit.text = value
	
func _get_text():
	if not TextEdit: return text
	return TextEdit.text

func _on_TextEdit_text_changed():
	emit_signal("text_changed")


func _on_TextureRect_pressed():
	TextEdit.insert_text_at_cursor("[Testing this]")
