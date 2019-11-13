extends PanelContainer

signal text_changed(value)

onready var ScriptContainer = find_node("ScriptContainer")
onready var FilePathEdit = find_node("FilePathEdit")
onready var CreateButton = find_node("CreateButton")

var data_id:String = ""
var data:Dictionary = {}

func set_data(data, filename):
	data_id = data.get("ID", "")
	self.data = data

	if not filename.empty() and filename.is_valid_filename():
		var file = ModFiles.get_file_as_text('data/text/generators/%s' % filename)
		if file:
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
