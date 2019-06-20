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
	ModList.clear()
	var filled = true
	var root = ModList.create_item()
	var dir := Directory.new()
	var file := File.new()
	var path = self.path + "/mods"
	if dir.dir_exists(path) and dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		while true:
			var current = dir.get_next()
			if not current or current.empty():
				break
			if not dir.current_is_dir():
				continue
			
			if file.open("%s/%s/_polymod_meta.json" % [path, current], File.READ) == OK:
				var json = parse_json(file.get_as_text())
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
		ModDescription.text = ""
	
func _check_valid_path():
	var dir := Directory.new()
	valid_path = dir.dir_exists(path) and dir.dir_exists(path + "/data") and dir.dir_exists(path + "/mods")
	
	if not valid_path:
		ModList.clear()
		CreateButton.disabled = true
		CreateButton.focus_mode = Control.FOCUS_NONE
		GamePathEdit.text = "Not a valid path"
		EditButton.disabled = true
		LoadButton.disabled = true
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
		print("Can't load, data needs save")
		return
		
	var meta = ModList.get_selected().get_metadata(Column.NAME)
	if meta and meta.has("mod"):
		Database.load_data(path, meta.get("mod"))
		current_mod_loaded = meta.get("mod")
		_fill_mod_list()
		LoadButton.release_focus()

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


func _on_ModList_item_rmb_selected(position):
	print("Edit metadata popup")
