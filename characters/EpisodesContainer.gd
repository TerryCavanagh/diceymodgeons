extends PanelContainer

onready var TabContainer = find_node("TabContainer")
onready var EpisodeList = find_node("EpisodeList")

onready var Data = find_node("Data")
onready var Generator = find_node("Generator")
onready var Scripts = find_node("Scripts")

onready var EpisodeAddPopup = find_node("EpisodeAddPopup")

var character:String = ""

func _ready():
	TabContainer.visible = false
	EpisodeList.process_data_func = funcref(self, "_process_data")
	EpisodeList.change_text_func = funcref(self, "_change_episode_text")
	#EpisodeList.modified_func = funcref(self, "_data_modified")

func setup(character):
	self.character = character
	EpisodeList.start_load()

func _process_data(data):
	var result = {}
	for key in data.keys():
		if data.get(key).get("Character", "") != character:
			continue

		result[key] = data[key]

	return result

func _change_episode_text(key):
	var data = Database.commit(Database.Table.EPISODES, Database.READ, key)
	return "%s. %s" % [data.get("Level", "?"), data.get("Episode Name", "???")]

func _add_episode(episode_name):
	var levels = _process_data(Database.read(Database.Table.EPISODES, EpisodeList.overwrite_mode))
	var level = levels.size() + 1
	var levelpack = Database.loaded_mod
	var key = '%s_%s_%s' % [levelpack.to_lower(), character.to_lower(), level]
	Database.commit(Database.Table.EPISODES, Database.CREATE, key)
	Database.commit(Database.Table.EPISODES, Database.UPDATE, key, "Levelpack", levelpack)
	Database.commit(Database.Table.EPISODES, Database.UPDATE, key, "Character", character)
	Database.commit(Database.Table.EPISODES, Database.UPDATE, key, "Level", level)
	Database.commit(Database.Table.EPISODES, Database.UPDATE, key, "Episode Name", episode_name)

	EpisodeList.force_reload(key)

func _on_EpisodeList_item_selected(key):
	if not key:
		TabContainer.visible = false
		return

	TabContainer.visible = true
	var data = Database.commit(Database.Table.EPISODES, Database.READ, key)
	Data.set_data(data)
	Scripts.set_data(data)
	Generator.set_data(data)

func _on_EpisodeList_add_button_pressed(overwrite_mode):
	EpisodeAddPopup.overwrite_mode = overwrite_mode
	EpisodeAddPopup.add_func = funcref(self, "_add_episode")
	EpisodeAddPopup.popup_centered(Vector2(400, 120))
