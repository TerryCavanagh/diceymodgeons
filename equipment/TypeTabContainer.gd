extends PanelContainer

enum TabType {
	NORMAL,
	UPGRADED,
	WEAKENED,
	DOWNGRADED,
	DECKUPGRADE
}

export (TabType) var type = TabType.NORMAL
export (TabType) var copy_from = TabType.NORMAL

onready var TabContainer = find_node("TabContainer")
onready var Data = find_node("Data")
onready var Scripts = find_node("Scripts")
onready var CreateContainer = find_node("CreateContainer")
onready var CreateButton = find_node("CreateButton")
onready var CopyButton = find_node("CopyButton")

var current_key:String = ""
var current_copy = copy_from

func _ready():
	_toggle_create_container(true)
	if type == TabType.NORMAL:
		CopyButton.visible = false
	else:
		Data.connect("equipment_deleted", self, "_on_equipment_deleted")
	
func set_key(key:String):
	if not TabContainer: return
	
	current_key = key
	
	if key == null or key.empty(): 
		_toggle_create_container(true)
		return
	
	var full_key = _get_full_key(type)
	
	var data = Database.commit(Database.Table.EQUIPMENT, Database.READ, full_key)
	if not data: 
		_toggle_create_container(true)
		return
	
	_toggle_create_container(false)
	
	Data.set_data(data)
	Scripts.set_data(data)
	
func _toggle_create_container(show:bool):
	if show:
		TabContainer.visible = false
		CreateContainer.visible = true
		
		current_copy = TabType.NORMAL
		if Database.commit(Database.Table.EQUIPMENT, Database.READ, _get_full_key(copy_from)):
			current_copy = copy_from
			
		CopyButton.text = "Copy from %s" % [TabType.keys()[current_copy].capitalize()]
		
	else:
		TabContainer.visible = true
		CreateContainer.visible = false
	
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
		TabType.DECKUPGRADE:
			key += "_deckupgrade"
			
	return key

func _on_CreateButton_pressed():
	var full_key = _get_full_key(type)
	if Database.commit(Database.Table.EQUIPMENT, Database.READ, full_key):
		ConfirmPopup.popup_accept("The equipment '%s' is already created." % full_key)
	elif Database.commit(Database.Table.EQUIPMENT, Database.CREATE, full_key):
		# Everything is correct
		pass
	else:
		ConfirmPopup.popup_accept("Something went wrong", "Ooops...")
		
	set_key(current_key)


func _on_CopyButton_pressed():
	var copy_key = _get_full_key(current_copy)
	var full_key = _get_full_key(type)
	if Database.commit(Database.Table.EQUIPMENT, Database.READ, full_key):
		ConfirmPopup.popup_accept("The equipment '%s' is already created." % copy_key)
	elif Database.commit(Database.Table.EQUIPMENT, Database.CREATE, full_key):
		var data = Database.commit(Database.Table.EQUIPMENT, Database.READ, copy_key)
		var db_table = Database.get_table(Database.Table.EQUIPMENT)
		for key in data:
			if key == db_table.KEY or key.count("__") > 0:
				continue
			var d = data[key]
			# if data is an array, create each value separately
			if typeof(d) == TYPE_ARRAY:
				for v in d:
					Database.commit(Database.Table.EQUIPMENT, Database.CREATE, full_key, key, v)
			else:
				Database.commit(Database.Table.EQUIPMENT, Database.CREATE, full_key, key, d)
		
		set_key(current_key)
	else:
		ConfirmPopup.popup_accept("Something went wrong", "Ooops...")
	
func _on_equipment_deleted(key):
	# Equipment was deleted, set it to empty
	set_key("")
