extends PanelContainer

onready var TabContainer = find_node("TabContainer")
onready var TreeList = find_node("ItemList")
onready var Data = find_node("Data")
onready var Graphics = find_node("Graphics")
onready var Scripts = find_node("Scripts")
onready var Chat = find_node("Chat")

onready var AddNewEnemyPopup = find_node("AddNewEnemyPopup")

func _ready():
	TabContainer.visible = false
	
func _add_enemy(value):
	var levelpack = "mod"
	var key = '%s_%s' % [levelpack.to_lower(), value.to_lower()]
	if TreeList.overwrite_mode:
		key = "overwrite__%s" % key
	Database.commit(Database.Table.FIGHTERS, Database.CREATE, key)
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, key, "Levelpack", levelpack)
	Database.commit(Database.Table.FIGHTERS, Database.UPDATE, key, "Name", value)
	
	TreeList.force_reload(key)

func _on_TreeList_item_selected(key):
	if not TabContainer: return
	if key == null or key.empty(): 
		TabContainer.visible = false
		return
	
	var data = Database.commit(Database.Table.FIGHTERS, Database.READ, key)
	TabContainer.visible = true
	Data.set_data(data)
	Graphics.set_data(data)
	Scripts.set_data(data)
	Chat.set_data(data)

func _on_TreeList_add_button_pressed(overwrite_mode):
	AddNewEnemyPopup.overwrite_mode = overwrite_mode
	AddNewEnemyPopup.add_func = funcref(self, "_add_enemy")
	AddNewEnemyPopup.popup_centered(Vector2(400, 120))
