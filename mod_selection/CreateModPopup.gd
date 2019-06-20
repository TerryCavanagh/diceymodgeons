extends WindowDialog

onready var IconTexture = find_node("IconTexture")
onready var TitleEdit = find_node("TitleEdit")
onready var AuthorEdit = find_node("AuthorEdit")
onready var ModVersionEdit = find_node("ModVersionEdit")
onready var LicenseEdit = find_node("LicenseEdit")
onready var DescriptionEdit = find_node("DescriptionEdit")
onready var SaveButton = find_node("SaveButton")
onready var CancelButton = find_node("CancelButton")
onready var FileDialog = find_node("FileDialog")

onready var okay_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)
onready var normal_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)
onready var wrong_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)

var data:Dictionary = {}

var default_mod_icon_path = "data/graphics/default_mod_icon.png"
var mod_icon_path = default_mod_icon_path

var current_mod:String = ""
var is_new_mod:bool = false

var valid:bool = false

func _ready():
	SaveButton.disabled = true
	okay_style.border_color = Color.green.darkened(0.5)
	wrong_style.border_color = Color.red.darkened(0.5)
	
func show_popup(mod:String = "", icon_path:String = "", data:Dictionary = {}):
	popup_centered_minsize(rect_min_size)
	
	current_mod = mod
	self.data = data
	if data.empty():
		window_title = "Create a new mod"
		SaveButton.text = "Create"
		is_new_mod = true
	else:
		window_title = "Edit the mod"
		SaveButton.text = "Edit"
		is_new_mod = false
		
	_set_icon(icon_path)
	
	_setup(TitleEdit, "title", "")
	_setup(AuthorEdit, "author", "")
	_setup(ModVersionEdit, "mod_version", "0.0.1")
	_setup(LicenseEdit, "license", "CC BY 4.0,MIT")
	_setup(DescriptionEdit, "description", "")
	
func _setup(node, key, def):
	if node is LineEdit:
		node.text = data.get(key, def)
		_check(node)
		Utils.connect_signal(node, key, "text_changed", self, "_on_LineEdit_text_changed")
	elif node is TextEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")

func _check(node):
	if not node: return false
	if node is LineEdit:
		if node.text.empty():
			node.add_stylebox_override("normal", wrong_style)
			return false
		else:
			node.add_stylebox_override("normal", okay_style)
			return true
	elif node is TextEdit:
		return true
		
	return false
	
func _set_icon(icon_path):
	var icon = null
	if not icon_path.empty():
		icon = Utils.load_external_texture(icon_path)
		
	if icon:
		mod_icon_path = icon_path
	else:
		mod_icon_path = Settings.get_value(Settings.GAME_PATH).plus_file(default_mod_icon_path)
		icon = Utils.load_external_texture(mod_icon_path)
		
	IconTexture.texture_normal = icon
	
func _on_LineEdit_text_changed(value, node, key):
	if _check(node):
		data[key] = node.text
	
func _on_TextEdit_text_changed(node, key):
	if _check(node):
		data[key] = node.text

func _on_SaveButton_pressed():
	if valid:
		var mods_path = Settings.get_value(Settings.GAME_PATH).plus_file("mods")
		
		if is_new_mod:
			current_mod = data.get("title").to_lower()
			var path = mods_path.plus_file(current_mod)
			# create dir
			var dir := Directory.new()
			if dir.dir_exists(path):
				print("Dir already exists at %s" % path)
			elif dir.make_dir_recursive(path) != OK:
				print("Couldn't create dir at %s" % path)
			
			# create json	
			var json = File.new()
			if json.open(path.plus_file("_polymod_meta.json"), File.WRITE) == OK:
				json.store_string(to_json(data))
				json.close()
			else:
				print("Couldn't create json")
			
			# create icon
			var icon_img = Image.new()
			if icon_img.load(mod_icon_path) == OK:
				if icon_img.save_png(path.plus_file("_polymod_icon.png")) != OK:
					print("Couldn't create icon")
			else:
				print("Couldn't load icon image")
			
			
			
		else:
			# update json
			# update icon
			pass


func _on_CancelButton_pressed():
	hide()

func _on_IconTexture_pressed():
	FileDialog.popup_centered_minsize(FileDialog.rect_min_size)

func _on_FileDialog_file_selected(path):
	_set_icon(path)
