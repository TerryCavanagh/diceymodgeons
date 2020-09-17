extends PanelContainer

const GeneratorFileScene = preload("res://characters/GeneratorFileContainer.tscn")
const EmptyFileScene = preload("res://characters/EmptyGeneratorTabContainer.tscn")

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
		add_generator_tab(generator)

	# load the text into somewhere that we can check if it's changed or not	(database?)
	# when saving we need to save the edited text coming from GAME to the mod folder!

	add_new_tab()

func add_generator_tab(generator, idx = -1):
	var filename = "%s.hx" % generator
	var file_container = GeneratorFileScene.instance()
	file_container.name = generator
	file_container.connect("delete_pressed", self, "_on_delete_pressed")
	FileTabContainer.add_child(file_container)
	if idx > -1:
		FileTabContainer.move_child(file_container, idx)
	file_container.set_data(data, filename)

func add_new_tab():
	var empty = EmptyFileScene.instance()
	empty.name = "+"
	empty.connect("create_pressed", self, "open_file_dialog")
	FileTabContainer.add_child(empty)
	new_tab_idx = empty.get_index()

func open_file_dialog():
	var path = ModFiles.get_mod_path("data/text/generators/")
	var dir = Directory.new()
	if not dir.dir_exists(path):
		dir.make_dir_recursive(path)
	GeneratorFileDialog.current_path = path
	GeneratorFileDialog.popup_centered_minsize(GeneratorFileDialog.rect_min_size)

func _on_FileTabContainer_tab_changed(tab):
	if tab == new_tab_idx:
		open_file_dialog()

func _on_GeneratorFileDialog_file_selected(path:String):
	var fname = path.get_file().get_basename()
	var current = Database.commit(Database.Table.EPISODES, Database.READ, data_id, "Generator")
	if current.has(fname):
		ConfirmPopup.popup_accept("The selected file is already in use.", "Warning")
		return
	if not path.get_extension().to_lower() == "hx":
		ConfirmPopup.popup_accept("The extension has to be 'hx'", "Warning")
		return
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		file.close()
		add_generator_tab(fname, new_tab_idx)
		FileTabContainer.current_tab = new_tab_idx
		new_tab_idx += 1
		Database.commit(Database.Table.EPISODES, Database.CREATE, data_id, "Generator", fname)
	else:
		print("Can't open file to write at %s" % path)

func _on_delete_pressed(file_name, node):
	ConfirmPopup.popup_confirm("Are you sure that you want to delete the file %s?" % file_name, "Are you sure?")
	var result = yield(ConfirmPopup, "action_chosen")
	match result:
		ConfirmPopup.OKAY:
			var path = ModFiles.get_mod_path("data/text/generators/%s" % file_name)
			var dir = Directory.new()
			if dir.remove(path) == OK:
				print('Delete correctly')
				FileTabContainer.remove_child(node)
				node.queue_free()
				Database.commit(Database.Table.EPISODES, Database.DELETE, data_id, "Generator", file_name.get_basename())
		ConfirmPopup.OTHER:
			pass
		ConfirmPopup.CANCEL:
			print("Delete Cancelled")
