extends PanelContainer

onready var ItemList = find_node("ItemList")
onready var DescriptionEdit = find_node("DescriptionEdit")
onready var RequirementOption = find_node("RequirementOption")
onready var RequirementValueOption = find_node("RequirementValueOption")
onready var ScriptContainer = find_node("ScriptContainer")

onready var ItemContainer = find_node("ItemContainer")

onready var AddNewItemPopup = find_node("AddNewItemPopup")

var data_id:String = ""
var data:Dictionary = {}

func _ready():
	ItemContainer.visible = false
	AddNewItemPopup.add_func = funcref(self, "_add_item")
	
func _add_item(value):
	Database.commit(Database.Table.SKILLS, Database.CREATE, value)

func set_data(data):
	data_id = Database.get_data_id(data, "Name")
	self.data = data
	
	_setup(DescriptionEdit, "Description", "")
	# TODO Requirements
	_setup(ScriptContainer, "Script", "")
	
func _setup(node, key, def):
	if node is TextEdit or node == DescriptionEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")
	if node == ScriptContainer:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_ScriptContainer_text_changed")
		
func _on_TextEdit_text_changed(node, key):
	if not data_id: return
	Database.commit(Database.Table.SKILLS, Database.UPDATE, data_id, key, node.text)
	
func _on_ScriptContainer_text_changed(text, node, key):
	if not data_id: return
	Database.commit(Database.Table.SKILLS, Database.UPDATE, data_id, key, text)

func _on_ItemList_item_selected(key):
	if key == null or key.empty():
		ItemContainer.visible = false
		return
		
	ItemContainer.visible = true
	var data = Database.commit(Database.Table.SKILLS, Database.READ, key)
	set_data(data)

func _on_ItemList_add_button_pressed(overwrite_mode):
	AddNewItemPopup.overwrite_mode = overwrite_mode
	AddNewItemPopup.popup_centered(Vector2(400, 120))
