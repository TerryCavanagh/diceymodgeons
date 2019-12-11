extends PanelContainer

const GeneratorFileScene = preload("res://characters/GeneratorFileContainer.tscn")

onready var FileTabContainer = find_node("FileTabContainer")
onready var GeneratorFileDialog = find_node("GeneratorFileDialog")

var data_id:String = ""
var data:Dictionary = {}

var new_tab_idx = -1

func set_data(data):
	data_id = Database.get_data_id(data, "ID")
	self.data = data
	
	for child in FileTabContainer.get_children():
		FileTabContainer.remove_child(child)
		child.queue_free()
	
	var generators = data.get("Generator", [])
	for generator in generators:
		var filename = "%s.hx" % generator
		var file_container = GeneratorFileScene.instance()
		file_container.name = generator
		FileTabContainer.add_child(file_container)
		file_container.set_data(data, filename)
	
	# load the text into somewhere that we can check if it's changed or not	(database?)
	# when saving we need to save the edited text coming from GAME to the mod folder!
	
	add_new_tab()

func add_new_tab():
	var empty = Control.new()
	empty.name = "+"
	FileTabContainer.add_child(empty)
	new_tab_idx = empty.get_index()

func _on_FileTabContainer_tab_changed(tab):
	if tab == new_tab_idx:
		var path = ModFiles.get_mod_path("data/text/generators/")
		var dir = Directory.new()
		if not dir.dir_exists(path):
			dir.make_dir_recursive(path)
		GeneratorFileDialog.current_path = path
		GeneratorFileDialog.popup_centered_minsize(GeneratorFileDialog.rect_min_size)

func _on_GeneratorFileDialog_file_selected(path):
	print("Create file %s" % path)
