extends PanelContainer

onready var GamePathEdit = find_node("GamePathEdit")
onready var ModList = find_node("ModList")
onready var ModDescription = find_node("ModDescription")
onready var WarningPopup = find_node("WarningPopup")
onready var FileDialogPopup = find_node("FileDialogPopup")
onready var CreateModPopup = find_node("CreateModPopup")
onready var CreateButton = find_node("CreateButton")
onready var EditButton = find_node("EditButton")
onready var LoadButton = find_node("LoadButton")
onready var LaunchButton = find_node("LaunchButton")

var path = null
var valid_path:bool = false

var current_mod_loaded:String = ""

enum Column {
	EDIT,
	NAME,
	AUTHOR,
	MOD_VERSION,
	API_VERSION,
	LICENSE,
}

func _ready():
	if not Settings.get_value(Settings.DONT_SHOW_WARNINGS, false):
		WarningPopup.popup_centered()

	path = Settings.get_value(Settings.GAME_PATH)

	if not path:
		path = OS.get_executable_path()

	if _check_valid_path():
		GamePathEdit.text = path
		_fill_mod_list()

	FileDialogPopup.current_dir = path

	ModList.columns = Column.size()
	ModList.set_column_titles_visible(true)
	ModList.set_column_title(Column.NAME, "Name")
	ModList.set_column_title(Column.AUTHOR, "Author")
	ModList.set_column_title(Column.MOD_VERSION, "Version")
	ModList.set_column_title(Column.API_VERSION, "API")
	ModList.set_column_title(Column.LICENSE, "Licenses")

	ModList.set_column_title(Column.EDIT, "")
	ModList.set_column_expand(Column.EDIT, false)
	ModList.set_column_min_width(Column.EDIT, 32)

func _fill_mod_list():
	if get_focus_owner():
		get_focus_owner().release_focus()

	ModList.clear()
	var filled = true
	var root = ModList.create_item()
	var dir := Directory.new()
	var file := File.new()
	var path = self.path + "/mods"

	var errors = []
	if dir.dir_exists(path) and dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		while true:
			var current = dir.get_next()
			if not current or current.empty():
				break
			if not dir.current_is_dir():
				continue

			if file.open("%s/%s/_polymod_meta.json" % [path, current], File.READ) == OK:
				var json = JSON.parse(file.get_as_text())
				if not json.error == OK:
					errors.push_back("\t- Mod %s has a _polymod_meta.json file but it is not a JSON valid file: (Line: %s) %s" % [current, json.error_line, json.error_string])
					continue
				json = json.result
				var item = ModList.create_item(root)
				var title = json.get("title", "")
				if title.empty():
					title = current
				item.set_text(Column.NAME, title)
				item.set_text(Column.AUTHOR, json.get("author", "?"))
				item.set_text(Column.MOD_VERSION, json.get("mod_version", "?"))
				item.set_text(Column.API_VERSION, json.get("api_version", "?"))
				item.set_text(Column.LICENSE, json.get("license", "?"))
				item.set_metadata(Column.NAME, {"mod": current, "polymod": json.duplicate(true)})

				item.set_cell_mode(Column.EDIT, TreeItem.CELL_MODE_STRING)
				item.set_editable(Column.EDIT, false)
				if current_mod_loaded == current:
					item.set_cell_mode(Column.EDIT, TreeItem.CELL_MODE_CHECK)
					item.set_checked(Column.EDIT, true)


				file.close()

		dir.list_dir_end()

		if root.get_children():
			filled = true
		else:
			filled = false
	else:
		filled = false

	if not filled or not ModList.get_selected():
		EditButton.disabled = true
		LoadButton.disabled = true
		LaunchButton.disabled = true
		ModDescription.text = ""

	if not errors.empty():
		var err_string  = PoolStringArray(errors).join("\n")
		ConfirmPopup.popup_accept("There were some errors filling the mod list:\n\n%s" % err_string, "Errors parsing mod's polymod metadata!", Vector2(1000, 300))

func _check_valid_path():
	var dir := Directory.new()
	var data_path = path
	if OS.get_name() == "OSX":
		data_path = path + "/diceydungeons.app/Contents/Resources/data"
	else:
		data_path = path + "/data"
	valid_path = dir.dir_exists(path) and dir.dir_exists(data_path) and dir.dir_exists(path + "/mods")

	if not valid_path:
		ModList.clear()
		CreateButton.disabled = true
		CreateButton.focus_mode = Control.FOCUS_NONE
		GamePathEdit.text = "Not a valid path"
		EditButton.disabled = true
		LoadButton.disabled = true
		LaunchButton.disabled = true
		ModDescription.text = ""
	else:
		CreateButton.focus_mode = Control.FOCUS_ALL
		CreateButton.disabled = false

	return valid_path

func _on_ChangeButton_pressed():
	FileDialogPopup.popup_centered_minsize(FileDialogPopup.rect_min_size)

func _on_CreateButton_pressed():
	CreateModPopup.show_popup()

func _on_EditButton_pressed():
	# TODO send the path too so it can actually save the data
	var meta = ModList.get_selected().get_metadata(Column.NAME)
	var icon_path = "%s/mods/%s/_polymod_icon.png" % [path, meta.get("mod", "")]
	CreateModPopup.show_popup(meta.get("mod", ""), icon_path, meta.get("polymod", {}))

func _on_LoadButton_pressed():
	if not valid_path: return
	if Database.data_needs_save():
		ConfirmPopup.popup_save("Save before changing mod?")
		var result = yield(ConfirmPopup, "action_chosen")
		match result:
			ConfirmPopup.OKAY:
				Database.save_data()
			ConfirmPopup.CANCEL:
				return
			ConfirmPopup.OTHER:
				# Don't save and load the other mod
				pass

	var meta = ModList.get_selected().get_metadata(Column.NAME)
	var loaded = true
	if meta and meta.has("mod"):
		var mod_api = meta.get("polymod", {}).get("api_version", "")
		var app_api = ProjectSettings.get_setting("application/config/mod_api_version")
		if not SemVerChecker.compare(mod_api, app_api):
			ConfirmPopup.popup_accept("The mod's API version differs from the supported API by the editor.", "Error!")
			yield(ConfirmPopup, "action_chosen")
			loaded = false

		if loaded:
			Database.load_data(path, meta)
			current_mod_loaded = meta.get("mod")
			_fill_mod_list()
			LoadButton.release_focus()
			LaunchButton.disabled = false
			GenerateSymbols.generate(current_mod_loaded)

func _on_FileDialogPopup_dir_selected(dir):
	path = dir
	if _check_valid_path():
		Settings.set_value(Settings.GAME_PATH, dir)
		GamePathEdit.text = dir
		_fill_mod_list()

func _on_ModList_item_selected():
	var meta = ModList.get_selected().get_metadata(Column.NAME)
	ModDescription.text = meta.get("polymod", {}).get("description", "")
	EditButton.disabled = false
	LoadButton.disabled = false


func _on_ModList_item_activated():
	_on_LoadButton_pressed()


func _on_CreateModPopup_popup_hide():
	_fill_mod_list()

func _on_LaunchButton_pressed():
	if not current_mod_loaded or current_mod_loaded.empty(): return

	if Database.data_needs_save():
		ConfirmPopup.popup_save("The data needs to be saved before launching the game.")
		var result = yield(ConfirmPopup, "action_chosen")
		match result:
			ConfirmPopup.OKAY:
				Database.save_data()
			ConfirmPopup.CANCEL:
				return
			ConfirmPopup.OTHER:
				# Don't save and launch without saving
				pass

	var mod = current_mod_loaded
	var exec = ""
	var exists = false
	match OS.get_name():
		"Windows":
			exec = path.plus_file("diceydungeons.exe")
			var file = File.new()
			exists = not exec.empty() and file.file_exists(exec)
		"OSX":
			exec = path.plus_file("diceydungeons.app")
			var dir = Directory.new()
			exists = not exec.empty() and dir.dir_exists(exec)
		"X11":
			pass
	var file = File.new()
	if exists:
		var pid = -1
		match OS.get_name():
			"Windows":
				pid = OS.execute(exec, ["mod=%s" % mod], false)
			"OSX":
				pid = OS.execute("open", [exec, "--args", "mod=%s" % mod], false)
			"X11":
				pass
		if pid == -1:
			ConfirmPopup.popup_accept("Something went wrong when trying to launch the game!")
		else:
			ConfirmPopup.popup_accept("Game is running.\nThe game will close itself when this alert is dismissed.")
			var result = yield(ConfirmPopup, "action_chosen")
			OS.kill(pid)
	else:
		ConfirmPopup.popup_accept("Couldn't find the game's executable.")
