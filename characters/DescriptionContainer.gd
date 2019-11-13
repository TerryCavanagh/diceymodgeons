extends PanelContainer

onready var InitialDescription = find_node("InitialDescription")
onready var MiddleDescription = find_node("MiddleDescription")
onready var EndgameDescription = find_node("EndgameDescription")
onready var PostEndgameDescription = find_node("PostEndgameDescription")

var data_id:String = ""
var data:Dictionary = {}

func set_data(data):
	data_id = data.get("ID", "")
	self.data = data
	_setup(InitialDescription, "Initial Description", "")
	_setup(MiddleDescription, "Middle Description", "")
	_setup(EndgameDescription, "Endgame Description", "")
	_setup(PostEndgameDescription, "Post Endgame Description", "")
	
func _setup(node:Node, key, def):
	if node is TextEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")
		
func _on_TextEdit_text_changed(node, key):
	if not data_id: return
	Database.commit(Database.Table.CHARACTERS, Database.UPDATE, data_id, key, node.text)
