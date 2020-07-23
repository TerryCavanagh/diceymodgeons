extends PanelContainer

signal text_changed(value)
signal delete_pressed(file_name, node)

onready var ScriptContainer = find_node("ScriptContainer")
onready var FilePathEdit = find_node("FilePathEdit")
onready var CreateButton = find_node("CreateButton")

var path = ""
var file_name = ""
var loaded_file:Dictionary = {}

func set_data(path, filename):
	if not filename.empty() and filename.is_valid_filename():
		file_name = filename
		self.path = path
		var file = ModFiles.get_file_as_text('data/text/scripts/%s' % filename)
		if file:
			loaded_file = file
			ScriptContainer.text = file.text
			FilePathEdit.text = file.path
			FilePathEdit.caret_position = FilePathEdit.text.length()
		else:
			FilePathEdit.clear()
			ScriptContainer.text = ""
			
func needs_save():
	return ModFiles.file_needs_save(path)

func _on_CreateButton_pressed():
	pass # Replace with function body.


func _on_DeleteButton_pressed():
	emit_signal("delete_pressed", path, self)

func _on_ScriptContainer_text_changed(new_text):
	loaded_file.changed_text = new_text
	emit_signal("text_changed", new_text)

