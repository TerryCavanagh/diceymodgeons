extends PanelContainer

onready var StatusList =  find_node("StatusList")
onready var StatusEffectContainer =  find_node("StatusEffectContainer")

func _ready():
	pass

func _on_StatusList_item_selected(key):
	if key == null or key.empty(): 
		return

	var data = Database.commit(Database.Table.STATUS_EFFECTS, Database.READ, key)
	StatusEffectContainer.set_data(data)
