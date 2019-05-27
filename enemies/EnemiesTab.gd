extends PanelContainer


onready var TabContainer = find_node("TabContainer")
onready var EnemyList = find_node("EnemyList")
onready var Data = find_node("Data")
onready var Graphics = find_node("Graphics")
onready var Scripts = find_node("Scripts")

func _ready():
	TabContainer.visible = false
	EnemyList.connect("enemy_selected", self, "_on_EnemyList_enemy_selected")
	
func _on_EnemyList_list_changed():
	TabContainer.visible = false

func _on_EnemyList_enemy_selected(key):
	if key == null or key.empty(): 
		TabContainer.visible = false
		return
	
	var data = Database.commit(Database.Table.FIGHTERS, Database.READ, key)
	TabContainer.visible = true
	Data.set_data(data)
	Graphics.set_data(data)
	Scripts.set_data(data)
