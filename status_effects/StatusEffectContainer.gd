extends PanelContainer

onready var SymbolsOption = find_node("SymbolsOption")
onready var DisplayAsEdit = find_node("DisplayAsEdit")
onready var DescriptionEdit = find_node("DescriptionEdit")
onready var RemoveStartTurnCheck = find_node("RemoveStartTurnCheck")
onready var RemoveEndTurnCheck = find_node("RemoveEndTurnCheck")
onready var StacksCheck = find_node("StacksCheck")
onready var InvisibleCheck = find_node("InvisibleCheck")
onready var BlockedByReduceCheck = find_node("BlockedByReduceCheck")

onready var ScriptsContainer = find_node("ScriptsContainer")

var data:Dictionary = {}
var data_id:String = ""

func _ready():
	GenerateSymbols.connect("symbols_loaded", self, "_on_symbols_loaded")

func set_data(data):
	data_id = Database.get_data_id(data, "Name")
	self.data = data

	_setup(SymbolsOption, "Symbol", "ice")
	_setup(DisplayAsEdit, "Displayed As", data_id)
	_setup(DescriptionEdit, "Description", "")
	_setup(StacksCheck, "Stacks?", false)
	_setup(RemoveEndTurnCheck, "Remove at End Turn?", false)
	_setup(RemoveStartTurnCheck, "Remove at Start Turn?", false)
	_setup(InvisibleCheck, "Invisible?", false)
	_setup(BlockedByReduceCheck, "Blocked By Reduce?", false)

	for child in ScriptsContainer.get_children():
		_setup_script(child, child.name, child.database_key, "")



func _setup(node, key, def):
	if node is CheckBox:
		node.pressed = data.get(key, def)
		Utils.connect_signal(node, key, "toggled", self, "_on_CheckBox_toggled")
	elif node == DisplayAsEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_LineEdit_text_changed")
	elif node == DescriptionEdit:
		node.text = data.get(key, def)
		Utils.connect_signal(node, key, "text_changed", self, "_on_TextEdit_text_changed")
	elif node == SymbolsOption:
		var value = data.get(key, def)
		for idx in SymbolsOption.get_item_count():
			var meta = SymbolsOption.get_item_metadata(idx)
			if meta == value:
				SymbolsOption.select(idx)
				break

		Utils.connect_signal(node, key, "item_selected", self, "_on_SymbolsOption_item_selected")

func _setup_script(node:Node, node_name, key, def):
	node.text = data.get(key, def)
	if not node.has_meta("original_name"):
		node.set_meta("original_name", node_name)
	_change_script_name(node, node.text.empty())
	Utils.connect_signal(node, key, "text_changed", self, "_on_StatusEffectScript_text_changed")

func _change_script_name(node, empty_text):
	if empty_text:
		node.name = node.get_meta("original_name")
	else:
		node.name = "[%s]" % node.get_meta("original_name")

func _on_StatusEffectScript_text_changed(text, node, key):
	if not data_id: return
	_change_script_name(node, text.empty())
	Database.commit(Database.Table.STATUS_EFFECTS, Database.UPDATE, data_id, key, text)

func _on_CheckBox_toggled(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.STATUS_EFFECTS, Database.UPDATE, data_id, key, value)

func _on_LineEdit_text_changed(value, node, key):
	if not data_id: return
	Database.commit(Database.Table.STATUS_EFFECTS, Database.UPDATE, data_id, key, value)

func _on_TextEdit_text_changed(node, key):
	if not data_id: return
	Database.commit(Database.Table.STATUS_EFFECTS, Database.UPDATE, data_id, key, node.text)

func _on_SymbolsOption_item_selected(idx, node, key):
	if not data_id: return
	var meta = SymbolsOption.get_item_metadata(idx)
	Database.commit(Database.Table.STATUS_EFFECTS, Database.UPDATE, data_id, key, meta)

func _on_symbols_loaded():
	SymbolsOption.clear()
	var idx = 0
	for symbol in Gamedata.symbols.keys():
		var data = Gamedata.symbols[symbol]
		var path = Gamedata.symbols.get(symbol).get("path_small", null)
		var texture = load(path)
		SymbolsOption.add_icon_item(texture, symbol)
		SymbolsOption.set_item_metadata(idx, symbol)
		idx += 1
