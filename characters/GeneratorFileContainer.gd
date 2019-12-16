extends PanelContainer

signal text_changed(value)
signal delete_pressed(file_name, node)

onready var ScriptContainer = find_node("ScriptContainer")
onready var FilePathEdit = find_node("FilePathEdit")
onready var CreateButton = find_node("CreateButton")

var data_id:String = ""
var data:Dictionary = {}

var file_name = ""
var loaded_file:Dictionary = {}

func set_data(data, filename):
	data_id = Database.get_data_id(data, "ID")
	self.data = data
	
	if not filename.empty() and filename.is_valid_filename():
		file_name = filename
		var file = ModFiles.get_file_as_text('data/text/generators/%s' % filename)
		if file:
			loaded_file = file
			ScriptContainer.text = file.text
			FilePathEdit.text = file.path
			if file.origin == ModFiles.Origin.GAME:
				CreateButton.text = "Overwrite"
			else:
				CreateButton.text = "Change"
		else:
			FilePathEdit.clear()
			ScriptContainer.text = ""
			CreateButton.text = "Create"


func _on_CreateButton_pressed():
	pass # Replace with function body.


func _on_DeleteButton_pressed():
	emit_signal("delete_pressed", file_name, self)

func _on_ScriptContainer_text_changed(new_text):
	loaded_file.changed_text = new_text
