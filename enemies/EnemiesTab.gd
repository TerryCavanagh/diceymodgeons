extends PanelContainer

onready var EnemyList = find_node("EnemyList")
onready var Data = find_node("Data")
onready var Graphics = find_node("Graphics")
onready var Scripts = find_node("Scripts")

func _ready():
	var i = 0
	var data = Database.commit(Database.Table.FIGHTERS, Database.READ)
	for key in data:
		EnemyList.add_item(key)
		EnemyList.set_item_metadata(i, key)
		i += 1
		
	EnemyList.sort_items_by_text()
	
	Database.connect("data_changed", self, "_on_data_changed")
	
	
func _on_data_changed(table, key, equals):
	if not table == Database.Table.FIGHTERS: return
	for i in EnemyList.get_item_count():
		if EnemyList.get_item_metadata(i) == key:
			var s = "%s (*)" % key if not equals else key
			EnemyList.set_item_text(i, s)
			break

func _on_EnemyList_item_selected(index):
	var meta = EnemyList.get_item_metadata(index)
	var data = Database.commit(Database.Table.FIGHTERS, Database.READ, meta)
	print(data["Name"])
	Data.set_data(data)
	Scripts.set_data(data)
