extends PanelContainer

onready var GamePathEdit = find_node("GamePathEdit")
onready var ModList = find_node("ModList")
onready var WarningPopup = find_node("WarningPopup")
onready var FileDialogPopup = find_node("FileDialogPopup")

var path = null
var valid_path:bool = false

func _ready():
	if not Settings.get_value(Settings.DONT_SHOW_WARNINGS, false):
		WarningPopup.popup_centered()
	path = Settings.get_value(Settings.GAME_PATH)
	
	if not path:
		path = OS.get_executable_path()
		
	if _check_valid_path():
		GamePathEdit.text = path
	else:
		GamePathEdit.text = "Please choose a path"
	
	FileDialogPopup.current_dir = path
	
func _check_valid_path():
	valid_path = false
	
	return false

func _on_ChangeButton_pressed():
	FileDialogPopup.popup_centered()

func _on_CreateButton_pressed():
	pass # Replace with function body.


func _on_FileDialogPopup_dir_selected(dir):
	pass # Replace with function body.
	path = dir
	if _check_valid_path():
		Settings.set_value(Settings.GAME_PATH, dir)
		GamePathEdit.text = dir
		Database.load_data(Database.root_path, "garfield")
	else:
		GamePathEdit.text = "Not a valid path"
