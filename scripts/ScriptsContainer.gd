extends PanelContainer

const ScriptFileScene = preload("res://scripts/ScriptFileContainer.tscn")
const CsvFileScene = preload("res://scripts/CsvFileContainer.tscn")
const EmptyTabScene = preload("res://scripts/EmptyTab.tscn")

export (String) var mod_path = "data/text/scripts/"

onready var FileTabContainer = find_node("FileTabContainer")
onready var ScriptsFileDialog = find_node("ScriptsFileDialog")

var new_tab_idx = -1

func _ready():
	add_empty_tab()
	Database.connect("all_tables_saved", self, "_on_database_save_completed")

func add_script_tab(path, fname, idx = -1):
	var script_container = null

	if fname.get_extension() == "csv":
		script_container = CsvFileScene.instance()
	else:
		script_container = ScriptFileScene.instance()

	script_container.connect("delete_pressed", self, "_on_delete_pressed")
	script_container.connect("close_pressed", self, "_on_close_pressed")
	script_container.connect("text_changed", self, "_on_script_text_changed")

	FileTabContainer.add_child(script_container)
	if idx > -1:
		FileTabContainer.move_child(script_container, idx)
	else:
		idx = FileTabContainer.get_child_count()-1

	FileTabContainer.set_tab_title(idx, fname)

	script_container.set_data(path, fname)

func add_empty_tab():
	var empty = EmptyTabScene.instance()
	empty.name = "+"
	empty.connect("create_pressed", self, "open_file_dialog", [FileDialog.MODE_SAVE_FILE])
	empty.connect("open_pressed", self, "open_file_dialog", [FileDialog.MODE_OPEN_FILE])
	FileTabContainer.add_child(empty)
	new_tab_idx = empty.get_index()

func open_file_dialog(mode):
	var path = ModFiles.get_mod_path(mod_path)
	var dir = Directory.new()
	if not dir.dir_exists(path):
		dir.make_dir_recursive(path)
	ScriptsFileDialog.current_path = path
	ScriptsFileDialog.current_file = ""
	ScriptsFileDialog.mode = mode
	ScriptsFileDialog.popup_centered_minsize(ScriptsFileDialog.rect_min_size)
	ScriptsFileDialog.deselect_items()

func close_tab(node:Node, path:String = ""):
	if not path.empty(): ModFiles.close_file(path)
	FileTabContainer.remove_child(node)
	node.queue_free()
	new_tab_idx -= 1

func _update_save_state():
	for idx in FileTabContainer.get_tab_count():
		var control = FileTabContainer.get_tab_control(idx)
		if not control.has_method("needs_save"): continue
		if control.needs_save():
			FileTabContainer.set_tab_title(idx, "%s (*)" % control.file_name)
		else:
			FileTabContainer.set_tab_title(idx, "%s" % control.file_name)

func _on_ScriptsFileDialog_file_selected(path:String):
	if ModFiles.is_file_opened(path):
		for idx in FileTabContainer.get_tab_count():
			var control = FileTabContainer.get_tab_control(idx)
			if control and control.path == path:
				FileTabContainer.current_tab = idx
				break
		return

	var fname = path.get_file()
	var file = File.new()
	var mode = File.WRITE
	if file.file_exists(path):
		mode = File.READ_WRITE
	if file.open(path, mode) == OK:
		file.close()
		add_script_tab(path, fname, new_tab_idx)
		FileTabContainer.current_tab = new_tab_idx
		new_tab_idx += 1
	else:
		print("Can't open file to write at %s" % path)

func _on_delete_pressed(path, node):
	ConfirmPopup.popup_confirm("Are you sure that you want to delete the file %s?" % path, "Are you sure?")
	var result = yield(ConfirmPopup, "action_chosen")
	match result:
		ConfirmPopup.OKAY:
			var dir = Directory.new()
			var op = dir.remove(path)
			if op == OK:
				print('Delete correctly')
				close_tab(node, path)

				#Database.commit(Database.Table.EPISODES, Database.DELETE, data_id, "Generator", file_name.get_basename())
			else:
				print('Could not delete it D: %s' % path)
		ConfirmPopup.OTHER:
			pass
		ConfirmPopup.CANCEL:
			print("Delete Cancelled")

func _on_close_pressed(path, node):
	var close = true

	if node.has_method("needs_save") and node.needs_save():
		ConfirmPopup.popup_save("The file needs to be saved first. Do you want to save it before closing it?", "Are you sure?")
		var result = yield(ConfirmPopup, "action_chosen")
		match result:
			ConfirmPopup.OKAY:
				ModFiles.save_file(path)
			ConfirmPopup.OTHER:
				pass
			ConfirmPopup.CANCEL:
				close = false

	if close:
		close_tab(node, path)

func _on_script_text_changed(new_text):
	_update_save_state()

func _on_database_save_completed():
	_update_save_state()
