extends Tree

signal element_selected(key)

const BUTTON_REVERT_ID = 1
const BUTTON_DELETE_ID = 2

var process_data_func:FuncRef = null
var modified_func:FuncRef = null

var delete_texture:Texture = null
var return_texture:Texture = null
var root:TreeItem = null

var filter = null

var table = null

enum Column {
	MODIFIED = 0,
	NAME = 1,
	BUTTON = 2,
}

func _ready():
	
	Database.connect("entry_created", self, "_on_entry_created")
	Database.connect("entry_key_changed", self, "_on_entry_key_changed")
	Database.connect("entry_updated", self, "_on_entry_updated")
	Database.connect("entry_deleted", self, "_on_entry_deleted")
	
	Database.connect("save_completed", self, "_on_save_completed")
	
	delete_texture = preload("res://assets/trascanOpen_20.png")
	return_texture = preload("res://assets/return_20.png")
	
	set_column_titles_visible(false)
	set_column_expand(Column.MODIFIED, false)
	set_column_expand(Column.NAME, true)
	set_column_expand(Column.BUTTON, false)
	set_column_min_width(Column.MODIFIED, 15)
	set_column_min_width(Column.BUTTON, 30)
	
func load_data(filter = null, select_key = null):
	self.filter = filter
	
	if not table: return
	
	var select_meta = {}
	if not select_key and get_selected():
		select_meta = get_selected().get_metadata(Column.NAME)
	
	var data = Database.commit(table, Database.READ)
	
	if process_data_func:
		data = process_data_func.call_func(data)
	
	var keys = data.keys()
	keys.sort()
	
	if filter:
		filter = filter.to_lower()
		var new_keys = []
		for key in keys:
			if key.findn(filter) > -1:
				new_keys.push_back(key)
		
		keys = new_keys
		
	clear()
	root = create_item()
	
	var still_selected = false
	for key in keys:
		var entry = data[key]
		var origin = entry.get("__origin", Database.Origin.GAME)
		var metadata = {"key":key, "origin":origin, "is_in_game_data": Database.get_table(table).is_in_game_data(key)}
		var item = create_item(root)
		_set_item_data(item, metadata)
		if select_meta.get("key", "") == key or select_key == key:
			item.select(0)
			still_selected = true
			
	ensure_cursor_is_visible()
	
	if not still_selected:
		emit_signal("element_selected", null)
		
func _modified(key):
	if modified_func:
		return modified_func.call_func(key)
	else:
		return not Database.get_table(table).compare(key)
	
func _set_item_data(item:TreeItem, metadata):
	var key = metadata.get("key", "")
	if key.empty(): return
	
	var origin = metadata.get("origin", Database.Origin.GAME)
	var modified = _modified(key)
	
	if modified:
		item.set_text(Column.MODIFIED, "*")
	else:
		item.set_text(Column.MODIFIED, "")
	
	item.set_text(Column.NAME, key)
	item.set_editable(Column.NAME, true)
	item.set_tooltip(Column.NAME, key)
	
	item.set_metadata(Column.NAME, metadata)
	
	item.set_selectable(Column.MODIFIED, false)
	item.set_selectable(Column.BUTTON, false)
	
	for i in item.get_button_count(Column.BUTTON):
		item.erase_button(Column.BUTTON, i)
		
	if metadata.get("is_in_game_data", false) and (modified or origin == Database.Origin.APPEND):
		item.add_button(Column.BUTTON, return_texture, BUTTON_REVERT_ID, false)
		item.set_tooltip(Column.BUTTON, "Revert to the game data")
	elif origin == Database.Origin.APPEND:
		item.add_button(Column.BUTTON, delete_texture, BUTTON_DELETE_ID, false)
		item.set_tooltip(Column.BUTTON, "Delete")

	
func _on_entry_created(table, key):
	if not table == self.table: return
	# TODO maybe move this
	# If key contains an underscore then remove the rest of the string
	if key.find("_") > -1:
		key = key.left(key.find("_"))
	load_data(filter, key)
	
func _on_entry_key_changed(table, old_key, new_key):
	if not table == self.table: return
	load_data(filter)
	
func _on_entry_deleted(table, key):
	if not table == self.table: return
	load_data(filter)
		
func _on_entry_updated(table, key, equals):
	if not table == self.table: return
	var child = root.get_children()
	# TODO maybe move this
	# If key contains an underscore then remove the rest of the string
	if key.find("_") > -1:
		key = key.left(key.find("_"))
		
	while child:
		var metadata = child.get_metadata(Column.NAME)
		var child_key = metadata.get("key", "")
		if child_key.empty():
			break
		
		if child_key == key:
			metadata.modified = not equals
			_set_item_data(child, metadata)
			break
			
		child = child.get_next()
		
func _on_save_completed(table):
	if not table == self.table: return
	load_data(filter)

func _on_List_item_selected():
	var item = get_selected()
	emit_signal("element_selected", item.get_metadata(Column.NAME).get("key", ""))

func _on_List_button_pressed(item, column, id):
	var meta = item.get_metadata(Column.NAME)
	match id:
		BUTTON_DELETE_ID:
			# TODO ask before deleting
			Database.commit(table, Database.DELETE, meta.key)
		BUTTON_REVERT_ID:
			# TODO ask before reverting])
			Database.commit(table, Database.DELETE, meta.key)
			
	emit_signal("element_selected", null)

func _on_Search_text_changed(new_text):
	load_data(new_text)

func _on_List_nothing_selected():
	emit_signal("element_selected", null)

func _on_List_item_edited():
	var item = get_selected()
	var meta = item.get_metadata(Column.NAME)
	var old_key = meta.get("key", "")
	var new_key = item.get_text(Column.NAME)
	if new_key.strip_edges().empty() or old_key == new_key:
		_set_item_data(item, meta)
		return
		
	Database.commit(table, Database.UPDATE, old_key, Database.get_table(table).KEY, new_key)
