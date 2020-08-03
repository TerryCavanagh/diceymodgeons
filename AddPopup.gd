extends WindowDialog

export (String) var empty_name_message = ""
export (String) var bad_name_message = ""
export (String) var exception_message = ""
export (String) var good_name_message = ""
export (Database.Table) var table = Database.Table.FIGHTERS
export (String) var field = ""

onready var NameEdit = find_node("NameEdit")
onready var StatusLabel = find_node("StatusLabel")
onready var OK = find_node("OK")
onready var Cancel = find_node("Cancel")

var add_func:FuncRef = null

var overwrite_mode:bool = false
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
		if n.findn("_") > -1 or n.findn("-") > -1:
			msg = exception_message
			valid = false

	if valid:
		var data = Database.read(table, overwrite_mode)
		for k in data.keys():
			var obj = data.get(k)
			if n == obj.get(field):
				valid = false
				break
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
	if add_func:
		add_func.call_func(NameEdit.text)
	else:
		assert(false, "Needs an add func")
	hide()

func _on_Cancel_pressed():
	hide()

func _on_AddPopup_about_to_show():
	NameEdit.clear()
	check_valid()
	NameEdit.call_deferred("grab_focus")

func _on_AddPopup_popup_hide():
	pass
