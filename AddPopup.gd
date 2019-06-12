extends WindowDialog

export (String) var empty_name_message = ""
export (String) var bad_name_message = ""
export (String) var exception_message = ""
export (String) var good_name_message = ""
export (Database.Table) var table = Database.Table.FIGHTERS

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
	var msg = empty_name_message
	if n.empty():
		valid = false
		
	if valid:
		if n.findn("_") > -1:
			msg = exception_message
			valid = false
		
	if valid:
		var exists = Database.commit(table, Database.READ, n)
		valid = not exists
		if not valid:
			msg = bad_name_message
		
	if valid:
		StatusLabel.modulate = Color.green
		StatusLabel.text = good_name_message
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
	Database.commit(table, Database.CREATE, NameEdit.text)
	hide()
	
func _on_Cancel_pressed():
	hide()


func _on_AddPopup_about_to_show():
	NameEdit.clear()
	check_valid()
	NameEdit.call_deferred("grab_focus")

func _on_AddPopup_popup_hide():
	pass
