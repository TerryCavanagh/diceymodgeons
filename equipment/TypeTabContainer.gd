extends PanelContainer

enum TabType {
	NORMAL,
	UPGRADED,
	WEAKENED,
	DOWNGRADED
}

export (TabType) var type = TabType.NORMAL

onready var TabContainer = find_node("TabContainer")
onready var Data = find_node("Data")
onready var Scripts = find_node("Scripts")
onready var CreateContainer = find_node("CreateContainer")
onready var CreateButton = find_node("CreateButton")
onready var CopyButton = find_node("CopyButton")

func _ready():
	TabContainer.visible = false
	CreateContainer.visible = true
	if type == TabType.NORMAL:
		CopyButton.visible = false
	
func set_key(key:String):
	if not TabContainer: return
	if key == null or key.empty(): 
		TabContainer.visible = false
		CreateContainer.visible = true
		return
	
	match type:
		TabType.NORMAL:
			pass
		TabType.UPGRADED:
			key += "_upgraded"
		TabType.WEAKENED:
			key += "_weakened"
		TabType.DOWNGRADED:
			key += "_downgraded"
	
	var data = Database.commit(Database.Table.EQUIPMENT, Database.READ, key)
	if not data: 
		TabContainer.visible = false
		CreateContainer.visible = true
		return
	
	TabContainer.visible = true
	CreateContainer.visible = false
	
	Data.set_data(data)
	Scripts.set_data(data)
	