extends WindowDialog

onready var IconTexture = find_node("IconTexture")
onready var DirNameEdit = find_node("DirNameEdit")
onready var TitleEdit = find_node("TitleEdit")
onready var AuthorEdit = find_node("AuthorEdit")
onready var ModVersionEdit = find_node("ModVersionEdit")
onready var LicenseEdit = find_node("LicenseEdit")
onready var DescriptionEdit = find_node("DescriptionEdit")
onready var SaveButton = find_node("SaveButton")
onready var CancelButton = find_node("CancelButton")
onready var FileDialog = find_node("FileDialog")

onready var DirNameMessage = find_node("DirNameMessage")
onready var ModVersionMessage = find_node("ModVersionMessage")

onready var okay_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)
onready var normal_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)
onready var wrong_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)

var data:Dictionary = {}

var default_mod_icon_path = "data/graphics/default_mod_icon.png"
var mod_icon_path = default_mod_icon_path

var current_mod:String = ""
var is_new_mod:bool = false

var valid_nodes := {}
var all_valid:bool = false

var dir_name_regex = RegEx.new()
var semver_regex = RegEx.new()

func _ready():
	dir_name_regex.compile("^[a-zA-Z0-9]+$")
	# from https://regexr.com/39s32
	semver_regex.compile("^((([0-9]+)\\.([0-9]+)\\.([0-9]+)(?:-([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?)(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?)$")
	SaveButton.disabled = true
	okay_style.border_color = Color.green.darkened(0.5)
	wrong_style.border_color = Color.red.darkened(0.5)

func _process(delta):
	all_valid = true
	for v in valid_nodes.values():
		if not v:
			all_valid = false
			break
	
	SaveButton.disabled = not all_valid
	
	
func show_popup(mod:String = "", icon_path:String = "", data:Dictionary = {}):
	popup_centered_minsize(rect_min_size)
	
	current_mod = mod
	self.data = data
	if data.empty():
		window_title = "Create a new mod"
		SaveButton.text = "Create"
		is_new_mod = true
		DirNameEdit.editable = true
		DirNameMessage.visible = true
		data["mod_version"] = "0.0.1"
		data["license"] = "CC BY 4.0,MIT"
		data["api_version"] = ProjectSettings.get_setting("application/config/mod_api_version")
	else:
		window_title = "Edit the mod"
		SaveButton.text = "Edit"
		is_new_mod = false
		DirNameEdit.editable = false
		DirNameMessage.visible = false
		
	_set_icon(icon_path)
	
	_setup(DirNameEdit, "dir", mod)
	_setup(TitleEdit, "title", "")
	_setup(AuthorEdit, "author", "")
	_setup(ModVersionEdit, "mod_version", "0.0.1")
	_setup(LicenseEdit, "license", "CC BY 4.0,MIT")
	_setup(DescriptionEdit, "description", "")
	
func _setup(node, key, def):
	if node is LineEdit:
		if key == "dir":
			node.text = current_mod
		else:
			node.text = data.get(key, def)
		_check(node)
		Utils.connect_signal(node, key, "text_changed", self, "_on_LineEdit_text_changed")
	elif node is TextEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")

var dir_check = Directory.new()
func _check(node):
	if not node: return false
	
	var result = false
	var dir_already_exists = false
	if node is LineEdit:
		if node.text.empty():
			result = false
		else:
			result = true
			if node == DirNameEdit:
				result = dir_name_regex.search(node.text) != null
				if result:
					var path = Settings.get_value(Settings.GAME_PATH).plus_file("mods").plus_file(node.text)
					result = not dir_check.dir_exists(path)
					dir_already_exists = dir_check.dir_exists(path)
			elif node == ModVersionEdit:
				result = semver_regex.search(node.text) != null
			
		if result:
			node.add_stylebox_override("normal", okay_style)
			if node == DirNameEdit:
				DirNameMessage.text = "Directory name correct."
			elif node == ModVersionEdit:
				ModVersionMessage.bbcode_text = "Mod version correct."
		else:
			node.add_stylebox_override("normal", wrong_style)
			if node == DirNameEdit:
				if dir_already_exists:
					DirNameMessage.text = "Directory already exists."
				else:
					DirNameMessage.text = "Can only contain alphanumeric characters."
			elif node == ModVersionEdit:
				ModVersionMessage.bbcode_text = "The mod version follows the SemVer Specification. [url=https://semver.org/]Read more here[/url]"
				
		if node == ModVersionEdit:
			var f = ModVersionMessage.get_font("normal_font")
			var h = f.get_wordwrap_string_size(ModVersionMessage.text, ModVersionMessage.rect_size.x).y
			ModVersionMessage.get_parent().rect_min_size.y = h + 8
			
	elif node is TextEdit:
		result = true
		
	valid_nodes[node] = result
	
	return result
	
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
	
func _error(text:String):
	ConfirmPopup.popup_accept(text, "Error!")
	#yield(ConfirmPopup, "action_chosen")
	#hide()
	
func _on_LineEdit_text_changed(value, node, key):
	if _check(node):
		if key == "dir":
			current_mod = node.text
		else:
			data[key] = node.text
	
func _on_TextEdit_text_changed(node, key):
	if _check(node):
		data[key] = node.text

func _on_SaveButton_pressed():
	var mods_path = Settings.get_value(Settings.GAME_PATH).plus_file("mods")
	print(current_mod)
	var path = mods_path.plus_file(current_mod)
	
	if is_new_mod:
		# create dir
		var dir := Directory.new()
		if dir.dir_exists(path):
			_error("Dir already exists at %s" % path)
			return
		elif dir.make_dir_recursive(path) != OK:
			_error("Couldn't create dir at %s" % path)
			return
	
	# create json	
	var json = File.new()
	if json.open(path.plus_file("_polymod_meta.json"), File.WRITE) == OK:
		json.store_string(to_json(data))
		json.close()
	else:
		_error("Couldn't create _polymod_meta.json")
		return
	
	# create icon
	var icon_img = Image.new()
	if icon_img.load(mod_icon_path) == OK:
		if icon_img.save_png(path.plus_file("_polymod_icon.png")) != OK:
			_error("Couldn't create _polymod_icon.png")
			return
	else:
		_error("Couldn't create _polymod_icon.png")
		return
		
	hide()

func _on_CancelButton_pressed():
	hide()

func _on_IconTexture_pressed():
	FileDialog.popup_centered_minsize(FileDialog.rect_min_size)

func _on_FileDialog_file_selected(path):
	_set_icon(path)


func _on_ModVersionMessage_meta_clicked(meta):
	OS.shell_open(meta)
