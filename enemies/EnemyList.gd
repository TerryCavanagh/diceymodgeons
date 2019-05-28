extends Tree

signal enemy_selected(key)

var delete_texture:Texture = null
var root:TreeItem = null

var filter = null

func _ready():
	
	Database.connect("entry_created", self, "_on_entry_created")
	Database.connect("entry_updated", self, "_on_entry_updated")
	Database.connect("entry_deleted", self, "_on_entry_deleted")
	
	var delete_img = preload("res://assets/trashcanOpen.png")
	delete_img.resize(24, 24, Image.INTERPOLATE_LANCZOS)
	
	delete_texture = ImageTexture.new()
	delete_texture.create_from_image(delete_img)
	
	set_column_titles_visible(false)
	set_column_expand(0, true)
	set_column_expand(1, false)
	
	load_data()
	
func load_data(filter = null):
	self.filter = filter
	var select_meta = {}
	if get_selected():
		select_meta = get_selected().get_metadata(0)
	
	var data = Database.commit(Database.Table.FIGHTERS, Database.READ)
	var keys = data.keys()
	keys.sort()
	
	if filter:
		filter = filter.to_lower()
		var new_keys = []
		for key in keys:
			if key.to_lower().begins_with(filter):
				new_keys.push_back(key)
		
		keys = new_keys
		
	clear()
	root = create_item()
	
	var still_selected = false
	for key in keys:
		var enemy = data[key]
		var origin = enemy.get("__from", "default")
		# TODO Remove the private thingy here
		var metadata = {"key":key, "origin":origin, "modified": not Database._fighters.compare(key)}
		var item = create_item(root)
		_set_item_data(item, metadata)
		if select_meta.get("key", "") == key:
			item.select(0)
			still_selected = true
	
	if not still_selected:
		emit_signal("enemy_selected", null)
	
func _set_item_data(item, metadata):
	var key = metadata.get("key", "")
	if key.empty(): return
	
	var origin = metadata.get("origin", "default")
	var modified = metadata.get("modified", false)
	
	var t = key
	if modified:
		t = "%s %s" % [key, "(*)"]
	
	item.set_text(0, t)
	item.set_text(1, origin)
	item.set_tooltip(0, key)
	item.set_tooltip(1, key)
	item.set_tooltip(2, "Delete")
	if item.get_button_count(2) > 0:
		item.erase_button(2, 0)
	item.add_button(2, delete_texture, 0, origin == "default")
	item.set_metadata(0, metadata)
	
func _on_entry_created(table, key):
	if not table == Database.Table.FIGHTERS: return
	load_data(filter)
	
func _on_entry_deleted(table, key):
	if not table == Database.Table.FIGHTERS: return
	load_data(filter)
		
func _on_entry_updated(table, key, equals):
	if not table == Database.Table.FIGHTERS: return
	var child = root.get_children()
	while child:
		var metadata = child.get_metadata(0)
		var child_key = metadata.get("key", "")
		if child_key == key:
			metadata.modified = not equals
			_set_item_data(child, metadata)
			break
			
		child = child.get_next()

func _on_EnemyList_item_selected():
	var item = get_selected()
	emit_signal("enemy_selected", item.get_metadata(0).get("key", ""))

func _on_EnemyList_button_pressed(item, column, id):
	print("Trying to remove %s" % [item.get_metadata(0).key])


func _on_Search_text_changed(new_text):
	load_data(new_text)

func _on_EnemyList_nothing_selected():
	emit_signal("enemy_selected", null)
