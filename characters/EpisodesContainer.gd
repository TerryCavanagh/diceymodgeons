extends PanelContainer

onready var EpisodeList = find_node("EpisodeList")

var character:String = ""

func _ready():
	EpisodeList.process_data_func = funcref(self, "_process_data")
	EpisodeList.change_text_func = funcref(self, "_change_episode_text")
	#EpisodeList.modified_func = funcref(self, "_data_modified")

func setup(character):
	self.character = character
	EpisodeList.start_load()
	"""
	data_id = Database.mixed_key(["Character", "Level"], data)
	self.data = data
	
	print(data_id)
	"""
	
func _process_data(d):
	var result = {}
	for key in d.keys():
		if d.get(key).get("Character", "") != character:
			continue
			
		result[key] = d[key]
	
	return result
	
func _change_episode_text(key):
	var data = Database.commit(Database.Table.EPISODES, Database.READ, key)
	return "%s. %s" % [data.get("Level", "?"), data.get("Episode Name", "???")]

func _on_EpisodeList_item_selected(key):
	print('Episode %s selected' % key)
