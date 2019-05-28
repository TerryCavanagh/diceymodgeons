extends WindowDialog

onready var NameEdit = find_node("NameEdit")
onready var StatusLabel = find_node("StatusLabel")
onready var OK = find_node("OK")
onready var Cancel = find_node("Cancel")

var valid := false

func _ready():
	pass
	
func check_valid():
	var n = NameEdit.text
	
	valid = true
	var msg = "The enemy needs a name"
	if n.empty():
		valid = false
		
	if valid:
		var exists = Database.commit(Database.Table.FIGHTERS, Database.READ, n)
		valid = not exists
		if not valid:
			msg = "That enemy already exists."
		
	if valid:
		StatusLabel.modulate = Color.green
		StatusLabel.text = "Great choice"
	else:
		StatusLabel.modulate = Color.red
		StatusLabel.text = msg
		
	
	OK.disabled = not valid
		
	
func _on_NameEdit_text_changed(new_text):
	check_valid()

func _on_NameEdit_text_entered(new_text):
	check_valid()
	_on_OK_pressed()

func _on_OK_pressed():
	if not valid: return
	Database.commit(Database.Table.FIGHTERS, Database.CREATE, NameEdit.text)
	hide()
	

func _on_Cancel_pressed():
	hide()


func _on_AddNewEnemyPopup_about_to_show():
	NameEdit.clear()
	check_valid()
