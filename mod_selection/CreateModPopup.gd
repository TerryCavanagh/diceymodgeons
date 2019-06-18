extends WindowDialog

onready var TitleEdit = find_node("TitleEdit")
onready var AuthorEdit = find_node("AuthorEdit")
onready var ModVersionEdit = find_node("ModVersionEdit")
onready var LicenseEdit = find_node("LicenseEdit")
onready var DescriptionEdit = find_node("DescriptionEdit")
onready var SaveButton = find_node("SaveButton")
onready var CancelButton = find_node("CancelButton")

var data:Dictionary = {}

func _ready():
	SaveButton.disabled = true
	
func show_popup(data:Dictionary = {}):
	popup_centered_minsize(rect_min_size)
	self.data = data
	if data.empty():
		window_title = "Create a new mod"
		SaveButton.text = "Create"
	else:
		window_title = "Edit the mod"
		SaveButton.text = "Edit"
		
	TitleEdit.text = data.get("title", "")
	AuthorEdit.text = data.get("author", "")
	ModVersionEdit.text = data.get("mod_version", "")
	LicenseEdit.text = data.get("license", "CC BY 4.0,MIT")
	DescriptionEdit.text = data.get("description", "")
	
	_check()

func _check():
	return false

func _on_SaveButton_pressed():
	if _check():
		pass
	else:
		pass


func _on_CancelButton_pressed():
	if _check():
		hide()
	else:
		pass
		# ask are you sure
		
	hide()
