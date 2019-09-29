extends PanelContainer

onready var DifficultySpin = find_node("DifficultySpin")
onready var EpisodesContainer = find_node("EpisodesContainer")

var data_id:String = ""
var data:Dictionary = {}

func set_data(data):
	data_id = data.get("Character", "")
	self.data = data
	
	_setup(DifficultySpin, "Difficulty", 1)

	EpisodesContainer.setup(data_id)

func _setup(node:Node, key, def):
	if node is SpinBox:
		node.value = data.get(key, def)
		Utils.connect_signal(node, key, "value_changed", self, "_on_SpinBox_value_changed")
		
func _on_SpinBox_value_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.CHARACTERS, Database.UPDATE, data_id, key, value)

