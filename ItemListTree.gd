extends Tree

signal element_selected(key)

var process_data_func:FuncRef = null

var delete_texture:Texture = null
var return_texture:Texture = null
var root:TreeItem = null

var filter = null

var table = null

func _ready():
	
	Database.connect("entry_created", self, "_on_entry_created")
	Database.connect("entry_key_changed", self, "_on_entry_key_changed")
	Database.connect("entry_updated", self, "_on_entry_updated")
	Database.connect("entry_deleted", self, "_on_entry_deleted")
	
	delete_texture = Utils.delete_texture
	return_texture = Utils.return_texture
	
	set_column_titles_visible(false)
	set_column_expand(0, true)
	set_column_expand(1, false)
	set_column_min_width(1, 30)
	
func load_data(filter = null):
	self.filter = filter
	
	if not table: return
	
	var select_meta = {}
	if get_selected():
		select_meta = get_selected().get_metadata(0)
	
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
		var enemy = data[key]
		var origin = enemy.get("__from", "default")
		var metadata = {"key":key, "origin":origin, "modified": not Database.get_table(table).compare(key)}
		var item = create_item(root)
		_set_item_data(item, metadata)
		if select_meta.get("key", "") == key:
			item.select(0)
			still_selected = true
			
	ensure_cursor_is_visible()
	
	if not still_selected:
		emit_signal("element_selected", null)
	
func _set_item_data(item, metadata):
	var key = metadata.get("key", "")
	if key.empty(): return
	
	var origin = metadata.get("origin", "default")
	var modified = metadata.get("modified", false)
	
	var t = key
	if modified:
		t = "%s %s" % [key, "(*)"]
	
	item.set_text(0, t)
	item.set_tooltip(0, key)
	
	item.set_metadata(0, metadata)
	
	if item.get_button_count(1) > 0:
		item.erase_button(1, 0)
	
	match origin:
		"default":
			pass
		"added":
			item.add_button(1, delete_texture, 0, false)
			item.set_tooltip(1, "Delete")
		"merged":
			item.add_button(1, return_texture, 0, false)
			item.set_tooltip(1, "Return to original")
	
func _on_entry_created(table, key):
	if not table == self.table: return
	load_data(filter)
	
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
		var metadata = child.get_metadata(0)
		var child_key = metadata.get("key", "")
		if child_key == key:
			metadata.modified = not equals
			_set_item_data(child, metadata)
			break
			
		child = child.get_next()

func _on_List_item_selected():
	var item = get_selected()
	emit_signal("element_selected", item.get_metadata(0).get("key", ""))

func _on_List_button_pressed(item, column, id):
	var meta = item.get_metadata(0)
	match meta.origin:
		"added":
			print("Trying to remove %s" % [meta.key])
		"merged":
			print("Trying to undo to original %s" % [meta.key])

func _on_Search_text_changed(new_text):
	load_data(new_text)

func _on_List_nothing_selected():
	emit_signal("element_selected", null)
