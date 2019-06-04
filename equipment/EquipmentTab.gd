extends PanelContainer

onready var TabContainer = find_node("TabContainer")
onready var ItemList = find_node("ItemList")
onready var Normal = find_node("Normal")
onready var Upgraded = find_node("Upgraded")
onready var Weakened = find_node("Weakened")
onready var Downgraded = find_node("Downgraded")
onready var Scripts = find_node("Scripts")


func _ready():
	TabContainer.visible = false
	
	ItemList.process_data_func = funcref(self, "_process_data")
	ItemList.start_load()
	
func _process_data(data):
	var result = {}
	for key in data.keys():
		if key.ends_with("_upgraded") or key.ends_with("_downgraded") or key.ends_with("weakened"):
			continue
			
		result[key] = data[key]
	
	return result
	
func _on_ItemList_item_selected(key):
	if not TabContainer: return
	if key == null or key.empty(): 
		TabContainer.visible = false
		return
	
	TabContainer.visible = true
	Normal.set_key(key)
	Upgraded.set_key(key)
	Weakened.set_key(key)
	Downgraded.set_key(key)


func _on_ItemList_add_button_pressed():
	#AddNewEnemyPopup.popup_centered(Vector2(400, 120))
	pass
