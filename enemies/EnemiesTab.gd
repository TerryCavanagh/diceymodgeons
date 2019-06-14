extends PanelContainer

onready var TabContainer = find_node("TabContainer")
onready var TreeList = find_node("ItemList")
onready var Data = find_node("Data")
onready var Graphics = find_node("Graphics")
onready var Scripts = find_node("Scripts")

onready var AddNewEnemyPopup = find_node("AddNewEnemyPopup")

func _ready():
	TabContainer.visible = false

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

func _on_TreeList_add_button_pressed():
	AddNewEnemyPopup.popup_centered(Vector2(400, 120))
