extends Tree

signal element_selected(key)

const BUTTON_REVERT_ID = 1
const BUTTON_DELETE_ID = 2

var process_data_func:FuncRef = null
var modified_func:FuncRef = null
var change_text_func:FuncRef = null

var delete_texture:Texture = null
var return_texture:Texture = null
var root:TreeItem = null

var sort_items:bool = true

var show_field:String = ""

var filter = null

var table = null

var overwrite_mode:bool = false

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
	
func force_reload(select_key = null):
	load_data(filter, select_key)
	
func load_data(filter = null, select_key = null):
	self.filter = filter
	
	if not table: return
	
	var select_meta = {}
	if not select_key and get_selected():
		select_meta = get_selected().get_metadata(Column.NAME)
	
	var data = Database.read(table, overwrite_mode)
	
	if process_data_func:
		data = process_data_func.call_func(data)
	
	var keys = data.keys()
	var fields = []
	for key in keys:
		fields.push_back({"key": key, "field": data.get(key).get(show_field, "")})
	if sort_items:
		fields.sort_custom(self, "_sort_fields")
		keys.clear()
		for field in fields:
			keys.push_back(field.get("key"))
	
	if filter:
		filter = filter.to_lower()
		var new_keys = []
		
		var tmp = {}
		for field in fields:
			var key = field.get("key")
			tmp[key] = field.get("field")
			if change_text_func:
				tmp[key] = change_text_func.call_func(key)
				
		for key in tmp.keys():
			if tmp.get(key).findn(filter) > -1:
				new_keys.push_back(key)
		
		keys = new_keys
		
	clear()
	root = create_item()
	
	var still_selected = false
	var t = Database.get_table(table)
	for key in keys:
		var entry = data[key]
		var origin = entry.get("__origin", Database.Origin.GAME)
		var metadata = {"key": key, "field": data[key].get(show_field, ""), "origin": origin, "is_in_game_data": t.is_in_game_data(key)}
		var item = create_item(root)
		_set_item_data(item, metadata)
		if select_meta.get("key", "") == key or select_key == key:
			item.select(Column.NAME)
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
	var is_in_game = metadata.get("is_in_game_data", false)
	var modified = _modified(key)
	
	if modified:
		item.set_text(Column.MODIFIED, "*")
		item.set_tooltip(Column.MODIFIED, "Item has been modified")
	else:
		item.set_text(Column.MODIFIED, "")
		item.set_tooltip(Column.MODIFIED, "")
	
	var n = metadata.get("field", "")
	if change_text_func:
		n = change_text_func.call_func(key)
	
	item.set_text(Column.NAME, n)
	#item.set_editable(Column.NAME, not is_in_game)
	item.set_tooltip(Column.NAME, n)
	
	item.set_metadata(Column.NAME, metadata)
	
	item.set_selectable(Column.MODIFIED, false)
	item.set_selectable(Column.BUTTON, false)
	
	for i in item.get_button_count(Column.BUTTON):
		item.erase_button(Column.BUTTON, i)
		
	if is_in_game and (modified or origin == Database.Origin.MERGE):
		item.add_button(Column.BUTTON, return_texture, BUTTON_REVERT_ID, false)
		item.set_tooltip(Column.BUTTON, "Revert to the game data")
	elif (origin == Database.Origin.APPEND or origin == Database.Origin.OVERWRITE):
		item.add_button(Column.BUTTON, delete_texture, BUTTON_DELETE_ID, false)
		item.set_tooltip(Column.BUTTON, "Delete")

func _sort_fields(a:Dictionary, b:Dictionary):
	return a.get("field").nocasecmp_to(b.get("field")) < 0
	
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
			ConfirmPopup.popup_confirm("Are you sure you want to delete '%s'?" % meta.field)
			var result = yield(ConfirmPopup, "action_chosen")
			if result == ConfirmPopup.OKAY:
				Database.commit(table, Database.DELETE, meta.key)
				emit_signal("element_selected", null)
		BUTTON_REVERT_ID:
			ConfirmPopup.popup_confirm("Are you sure you want to revert '%s' to the original game data?" % meta.field)
			var result = yield(ConfirmPopup, "action_chosen")
			print(result)
			if result == ConfirmPopup.OKAY:
				Database.commit(table, Database.DELETE, meta.key)
				emit_signal("element_selected", null)

func _on_Search_text_changed(new_text):
	load_data(new_text)

func _on_List_nothing_selected():
	emit_signal("element_selected", null)

func _on_List_item_edited():
	return
	assert(false) # TODO fix it to point to the edited field
	var item = get_selected()
	var meta = item.get_metadata(Column.NAME)
	var old_key = meta.get("key", "")
	var new_key = item.get_text(Column.NAME)
	if new_key.strip_edges().empty() or old_key == new_key:
		_set_item_data(item, meta)
		return
		
	Database.commit(table, Database.UPDATE, old_key, Database.get_table(table).KEY, new_key)
