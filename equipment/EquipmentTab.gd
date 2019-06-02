extends PanelContainer

onready var TabContainer = find_node("TabContainer")
onready var ItemList = find_node("ItemList")
onready var Data = find_node("Data")
onready var Scripts = find_node("Scripts")


func _ready():
	TabContainer.visible = false
	
func _on_ItemList_item_selected(key):
	if not TabContainer: return
	if key == null or key.empty(): 
		TabContainer.visible = false
		return
	
	var data = Database.commit(Database.Table.EQUIPMENT, Database.READ, key)
	TabContainer.visible = true
	Data.set_data(data)
	Scripts.set_data(data)

func _on_ItemList_add_button_pressed():
	#AddNewEnemyPopup.popup_centered(Vector2(400, 120))
	pass
