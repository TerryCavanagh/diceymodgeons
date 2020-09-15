extends PanelContainer

onready var VoiceEdit = find_node("VoiceEdit")
onready var ChatVoiceEdit = find_node("ChatVoiceEdit")
onready var ChatStyleEdit = find_node("ChatStyleEdit")

onready var AlwaysFirstWordsCheck = find_node("AlwaysFirstWordsCheck")
onready var AlwaysLastWordsCheck = find_node("AlwaysLastWordsCheck")

onready var FirstWordsEdit = find_node("FirstWordsEdit")
onready var LastWords1Edit = find_node("LastWords1Edit")
onready var LastWords2Edit = find_node("LastWords2Edit")
onready var LastWords3Edit = find_node("LastWords3Edit")
onready var LastWordsIfTheyWinEdit = find_node("LastWordsIfTheyWinEdit")
onready var LastWordsEndgameEdit = find_node("LastWordsEndgameEdit")

onready var VoiceFileDialog = find_node("VoiceFileDialog")

var data_id:String = ""
var data:Dictionary = {}

func set_data(data):
	data_id = Database.get_data_id(data, "ID")
	self.data = data

	_setup(VoiceEdit, "Voice", "")
	_setup(ChatVoiceEdit, "Chat Voice", "chat_monster1")
	_setup(ChatStyleEdit, "Chat Style", "looping")

	_setup(AlwaysFirstWordsCheck, "Always say First Words?", false)
	_setup(AlwaysLastWordsCheck, "Always say Last Words?", false)

	_setup(FirstWordsEdit, "First Words", "")
	_setup(LastWords1Edit, "Last Words 1", "")
	_setup(LastWords2Edit, "Last Words 2", "")
	_setup(LastWords3Edit, "Last Words 3", "")
	_setup(LastWordsIfTheyWinEdit, "Last Words (if they win)", "")
	_setup(LastWordsEndgameEdit, "Last Words Endgame", "")

func _setup(node, key, def):
	if node is LineEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_LineEdit_text_changed")
	elif node is CheckBox:
		node.pressed = data.get(key, def)
		Utils.connect_signal(node, key, "toggled", self, "_on_CheckBox_toggled")
	elif node is TextEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")

func _on_LineEdit_text_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, value)

func _on_CheckBox_toggled(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, value)

func _on_TextEdit_text_changed(node, key):
	if not data_id: return
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, data_id, key, node.text)


func _on_VoiceGameButton_pressed():
	var path = ModFiles.game_root_path + "/soundstuff"
	VoiceFileDialog.current_dir = path

	VoiceFileDialog.popup_centered_minsize(VoiceFileDialog.rect_min_size)


func _on_VoiceModButton_pressed():
	var path = ModFiles.game_root_path + "/" + ModFiles.mod_root_path + "/soundstuff"
	VoiceFileDialog.current_dir = path

	VoiceFileDialog.popup_centered_minsize(VoiceFileDialog.rect_min_size)

func _on_VoiceFileDialog_dir_selected(dir:String):
	var idx = dir.find_last("/soundstuff")

	if idx > -1:
		idx = clamp(idx + "/soundstuff/".length(), 0, dir.length())
		var path = ""
		if idx < dir.length():
			path = dir.right(idx)
			VoiceEdit.text = path
			VoiceEdit.emit_signal("text_changed", path)
		else:
			ConfirmPopup.popup_accept("The selected directory is empty!", "Oh...")
