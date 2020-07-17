extends PanelContainer

onready var StatusList =  find_node("StatusList")
onready var StatusEffectContainer =  find_node("StatusEffectContainer")
onready var AddNewStatusEffectPopup = find_node("AddNewStatusEffectPopup")

func _ready():
	StatusEffectContainer.visible = false
	AddNewStatusEffectPopup.add_func = funcref(self, "_add_status_effect")

func _add_status_effect(value):
	Database.commit(Database.Table.STATUS_EFFECTS, Database.CREATE, value)

func _on_StatusList_item_selected(key):
	if key == null or key.empty(): 
		return

	var data = Database.commit(Database.Table.STATUS_EFFECTS, Database.READ, key)
	StatusEffectContainer.set_data(data)
	StatusEffectContainer.visible = true


func _on_StatusList_add_button_pressed(overwrite_mode):
	AddNewStatusEffectPopup.overwrite_mode = overwrite_mode
	AddNewStatusEffectPopup.popup_centered(Vector2(400, 120))
