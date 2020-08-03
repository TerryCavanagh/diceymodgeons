extends PanelContainer

onready var TabContainer = find_node("TabContainer")
onready var CharacterList = find_node("CharacterList")

onready var Data = find_node("Data")
onready var Graphics = find_node("Graphics")
onready var Descriptions = find_node("Descriptions")

onready var CharacterAddPopup = find_node("CharacterAddPopup")

func _ready():
	TabContainer.visible = false

func _add_character(char_name):
	var levelpack = Database.loaded_mod
	var key = '%s_%s' % [levelpack.to_lower(), char_name.to_lower()]
	Database.commit(Database.Table.CHARACTERS, Database.CREATE, key)
	Database.commit(Database.Table.CHARACTERS, Database.UPDATE, key, "Levelpack", levelpack)
	Database.commit(Database.Table.CHARACTERS, Database.UPDATE, key, "Character", char_name)

	CharacterList.force_reload(key)

func _on_CharacterList_item_selected(key):
	if not TabContainer: return
	if key == null or key.empty():
		TabContainer.visible = false
		return

	var data = Database.commit(Database.Table.CHARACTERS, Database.READ, key)
	TabContainer.visible = true
	Data.set_data(data)
	Descriptions.set_data(data)

func _on_CharacterList_add_button_pressed(overwrite_mode):
	CharacterAddPopup.overwrite_mode = overwrite_mode
	CharacterAddPopup.add_func = funcref(self, "_add_character")
	CharacterAddPopup.popup_centered(Vector2(400, 120))


func _on_CharacterList_overwrite_mode_changed(new_value):
	# This is kinda dirty but oh well
	Data.EpisodesContainer.EpisodeList.force_overwrite_mode(new_value)
