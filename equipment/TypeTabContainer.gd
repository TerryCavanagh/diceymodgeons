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

var current_key:String = ""

func _ready():
	TabContainer.visible = false
	CreateContainer.visible = true
	if type == TabType.NORMAL:
		CopyButton.visible = false
	
func set_key(key:String):
	if not TabContainer: return
	
	current_key = key
	
	if key == null or key.empty(): 
		TabContainer.visible = false
		CreateContainer.visible = true
		return
	
	var full_key = _get_full_key(type)
	
	var data = Database.commit(Database.Table.EQUIPMENT, Database.READ, full_key)
	if not data: 
		TabContainer.visible = false
		CreateContainer.visible = true
		return
		
	TabContainer.visible = true
	CreateContainer.visible = false
	
	Data.set_data(data)
	Scripts.set_data(data)
	
func _get_full_key(type):
	var key = current_key
	match type:
		TabType.NORMAL:
			pass
		TabType.UPGRADED:
			key += "_upgraded"
		TabType.WEAKENED:
			key += "_weakened"
		TabType.DOWNGRADED:
			key += "_downgraded"
			
	return key

func _on_CreateButton_pressed():
	var full_key = _get_full_key(type)
	if Database.commit(Database.Table.EQUIPMENT, Database.READ, full_key):
		print("Can't create something that's already created")
	elif Database.commit(Database.Table.EQUIPMENT, Database.CREATE, full_key):
		print("%s created successfully" % full_key)
	else:
		print("Uhm, something went wrong")
		
	set_key(current_key)


func _on_CopyButton_pressed():
	pass # Replace with function body.
