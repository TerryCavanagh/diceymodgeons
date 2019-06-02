extends PanelContainer

onready var SizeOption = find_node("SizeOption")
onready var CategoryOption = find_node("CategoryOption")
onready var ColorOption = find_node("ColorOption")

onready var UsesSpin = find_node("UsesSpin")
onready var SpellSpin = find_node("SpellSpin")

onready var UpgradeOption = find_node("UpgradeOption")
onready var WeakenOption = find_node("WeakenOption")

var data_id:String = ""
var data:Dictionary = {}

func _ready():
	SizeOption.set_meta("list", ["1", "2"])
	
	var list = Gamedata.items.get("categories", [])
	for category in list:
		CategoryOption.add_item(category.capitalize())
		
	var popup = CategoryOption.get_popup()
	for i in list.size():
		popup.set_item_tooltip(i, "Testing " + str(i))
		
	CategoryOption.set_meta("list", list)
	list = Gamedata.items.get("colors", [])
	for color in list:
		ColorOption.add_item(color.capitalize())
	ColorOption.set_meta("list", list)
	
	list = Gamedata.items.get("upgrade_modifier", [])
	for upgrade in list:
		UpgradeOption.add_item(upgrade)
	UpgradeOption.set_meta("list", list)
	list = Gamedata.items.get("weaken_modifier", [])
	for weaken in list:
		WeakenOption.add_item(weaken)
	WeakenOption.set_meta("list", list)
	
	
func set_data(data):
	data_id = data.get("Name", "")
	self.data = data
	
	_setup(SizeOption, "Size", 1)
	_setup(CategoryOption, "Category", "")
	_setup(ColorOption, "Colour", "")
	
	_setup(UsesSpin, "Uses?", 0)
	_setup(SpellSpin, "Witch Spell", 0)
	
	_setup(UpgradeOption, "Upgrade", "")
	_setup(WeakenOption, "Weaken", "")
	
func _setup(node, key, def):
	if node is SpinBox:
		node.value = data.get(key, def)
		_connect(node, key, "value_changed", "_on_SpinBox_value_changed")
	elif node is LineEdit:
		node.text = data.get(key, def)
		_connect(node, key, "text_changed", "_on_LineEdit_text_changed")
	elif node is CheckBox:
		node.pressed = data.get(key, def)
		_connect(node, key, "toggled", "_on_CheckBox_toggled")
	elif node is TextEdit:
		node.text = data.get(key, def)
		_connect(node, key, "text_changed", "_on_TextEdit_text_changed")
	elif node is OptionButton:
		var s = str(data.get(key, def))
		if s.empty():
			node.select(0)
		else:
			var list = node.get_meta("list")
			node.select(list.find(s))
		_connect(node, key, "item_selected", "_on_OptionButton_item_selected")
	else:
		printerr("Node %s couldn't be setup" % node.name)
		
func _connect(node, key, _signal, _func):
	var param = [_signal, self, _func]
	if node.callv("is_connected", param):
		node.callv("disconnect", param)
	param.push_back([node, key])
	node.callv("connect", param)
	
func _on_SpinBox_value_changed(value, node, key):
	if not data_id: return

func _on_LineEdit_text_changed(value, node, key):
	if not data_id: return
	
func _on_CheckBox_toggle(value, node, key):
	if not data_id: return
	
func _on_TextEdit_text_changed(node, key):
	if not data_id: return
	
func _on_OptionButton_item_selected(id, node, key):
	if not data_id: return