extends HBoxContainer

signal delete_pressed()


export (String) var label_text = ""
export var text = "" setget _set_text, _get_text

onready var FileLabel = find_node("FileLabel")
onready var FilePathEdit = find_node("FilePathEdit")

func _ready():
	FileLabel.text = label_text
	self.text = text

func clear():
	FilePathEdit.clear()

func _set_text(value):
	text = value
	if FilePathEdit:
		FilePathEdit.text = text
		FilePathEdit.caret_position = FilePathEdit.text.length()

func _get_text():
	return FilePathEdit.text if FilePathEdit else text

func _on_DeleteButton_pressed() -> void:
	emit_signal("delete_pressed")
