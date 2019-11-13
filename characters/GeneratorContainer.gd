extends PanelContainer

const GeneratorFileScene = preload("res://characters/GeneratorFileContainer.tscn")
const GeneratorEmptyScene = preload("res://characters/EmptyGeneratorTabContainer.tscn")

onready var FileTabContainer = find_node("FileTabContainer")
onready var GeneratorFileDialog = find_node("GeneratorFileDialog")

var data_id:String = ""
var data:Dictionary = {}

func set_data(data):
	data_id = data.get("ID", "")
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
		
	var empty = GeneratorEmptyScene.instance()
	empty.name = "+"
	FileTabContainer.add_child(empty)
