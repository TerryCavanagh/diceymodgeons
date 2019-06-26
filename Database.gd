extends Node

signal entry_created(table, key)
signal entry_key_changed(table, old_key, new_key)
signal entry_updated(table, key, equals)
signal entry_deleted(table, key)

signal data_loaded()
signal save_completed(table)
signal all_tables_saved()

var root_path:String = ""
var mod_path:String = ""

var _fighters:CSVData = null
var _equipment:CSVData = null
var _items:CSVData = null
var _status_effects:CSVData = null

var _data_loaded = false

enum {CREATE,READ,UPDATE,DELETE}

enum Table {
	NONE,
	FIGHTERS,
	EQUIPMENT,
	ITEMS,
	STATUS_EFFECTS,
}

enum Origin {
	GAME,
	APPEND,
	MERGE,
}

#var undo_redo = UndoRedo.new()

func _init():
	root_path = "res://test"
	mod_path = "mods/garfield"
	_data_loaded = false
	
func _get_paths(table:int):
	var file = ""
	var schema = ""
	match table:
		Table.FIGHTERS:
			file = "fighters.csv"
			schema = "fighters_schema.json"
		Table.EQUIPMENT:
			file = "equipment.csv"
			schema = "equipment_schema.json"
		Table.ITEMS:
			file = "items.csv"
			schema = "items_schema.json"
		Table.STATUS_EFFECTS:
			file = "statuseffects.csv"
			schema = "statuseffects_schema.json"
			
	var result = {}
	
	result["schema"] = "res://assets/api_%s/%s" % [ProjectSettings.get_setting("application/config/mod_api_version"), schema]
	
	result[Origin.GAME] = "%s/data/text/%s" % [root_path, file]
	result[Origin.APPEND] = "%s/%s/_append/data/text/%s" % [root_path, mod_path, file]
	result[Origin.MERGE] = "%s/%s/_merge/data/text/%s" % [root_path, mod_path, file]
	
	return result
	
func data_needs_save():
	if not _data_loaded: return false
	
	for key in Table.keys():
		var table = Table.get(key)
		if table == Table.NONE: continue
		if get_table(table).data_needs_save():
			return true
	return false
	
func load_data(root_path:String, metadata:Dictionary):
	if not metadata.has("mod"): return
	
	self.root_path = root_path
	self.mod_path = 'mods/%s' % metadata.get("mod")
	
	_fighters = CSVData.new(_get_paths(Table.FIGHTERS), "Name")
	_equipment = CSVData.new(_get_paths(Table.EQUIPMENT), "Name")
	_items = CSVData.new(_get_paths(Table.ITEMS), "Name")
	_status_effects = CSVData.new(_get_paths(Table.STATUS_EFFECTS), "Name")
	
	_data_loaded = true
	emit_signal("data_loaded", metadata.get("polymod", {}).get("title", metadata.get("mod")))
	
func save_data():
	if not data_needs_save(): return
	
	_fighters.save_data()
	emit_signal("save_completed", Table.FIGHTERS)
	_equipment.save_data()
	emit_signal("save_completed", Table.EQUIPMENT)
	_items.save_data()
	emit_signal("save_completed", Table.ITEMS)
	_status_effects.save_data()
	emit_signal("save_completed", Table.STATUS_EFFECTS)
	
	emit_signal("all_tables_saved")
	
func get_table(table):
	match table:
		Table.FIGHTERS:
			return _fighters
		Table.EQUIPMENT:
			return _equipment
		Table.ITEMS:
			return _items
		Table.STATUS_EFFECTS:
			return _status_effects
		_:
			return null
	
func commit(table:int, action:int, key = null, field = null, value = null):
	"""
	Makes a database commit.
	- table: The database table
	- action: The action (CREATE, READ, UPDATE, DELETE)
	- key: The data key
	- field: The field
	- Value: The value
	"""
	var data = get_table(table)
			
	if not data:
		return null
		
	var result = null
	match action:
		CREATE:
			print_debug("CREATE %s: %s (%s) = %s" % [table, key, field, value])
			result = _create(data, key, field, value)
			if result:
				if key != null and field == null:
					emit_signal("entry_created", table, key)
				elif key != null and field != null:
					emit_signal("entry_updated", table, key, data.compare(key))
		READ:
			#print_debug("READ %s: %s (%s) = %s" % [table, key, field, value])
			result = _read(data, key, field)
		UPDATE:
			print_debug("UPDATE %s: %s (%s) = %s" % [table, key, field, value])
			if field == data.KEY:
				field = null
			result = _update(data, key, field, value)
			if result:
				if key != null and field == null:
					emit_signal("entry_key_changed", table, key, value)
				else:
					emit_signal("entry_updated", table, key, data.compare(key))
		DELETE:
			print_debug("DELETE %s: %s (%s) = %s" % [table, key, field, value])
			result = _delete(data, key, field, value)
			if result:
				if key != null and field == null:
					emit_signal("entry_deleted", table, key)
				elif key != null and field != null:
					emit_signal("entry_updated", table, key, data.compare(key))
		
	return result
	
	
func _create(data, key, field, value):
	match [key == null, field == null]:
		[true, true]:
			# do nothing, if both are null we can't create anything
			pass
		[true, false]:
			# if we only have the field, create/override it in every entry
			for k in data.data.keys():
				data.data[k][field] = value
			return true
		[false, true]:
			# if we only have the key, create an empty dictionary
			if not data.find(key):
				data.create(key)
				return true
		[false, false]:
			# if it's an array, append the value, if not create/override the value
			var obj = data.find(key)
			if obj:
				var f = obj.get(field, null)
				if typeof(f) == TYPE_ARRAY:
					f.push_back(value)
					f.sort()
				else:
					obj[field] = value
				return true
				
	return false
	
func _read(data, key, field):
	match [key == null, field == null]:
		[true, true]:
			# if both are null, return the whole data
			return data.data
		[false, true]:
			# if only the field is null, return the whole object
			return data.find(key)
		[false, false]:
			# if none are null, return the field
			var obj = data.find(key)
			if obj:
				return obj.get(field, null)
			else:
				return null
		[true, false]:
			# if only the key is null, return the value of all the objects of the field
			if field == data.KEY:
				return data.data.keys()
			else:
				var result = []
				for content in data.data:
					result.push_back(content.get(field, null))
				return result
		
	return null
	
func _update(data, key, field, value):
	match [key == null, field == null]:
		[true, true]:
			# do nothing, if both are null it can't be updated
			return false
		[true, false]:
			# do nothing, if we only have the field we can't update it alone
			return false
		[false, false]:
			var obj = data.find(key)
			if obj and obj.has(field):
				obj[field] = value
				return true
		[false, true]:
			# if we only have the key it means that we want to update the key itself
			if value == null: 
				return false
				
			return data.change_key(key, value)
				
	return false

func _delete(data, key, field, value):
	match [key == null, field == null]:
		[true, true]:
			# do nothing, we can't erease the whole data
			return false
		[true, false]:
			# do nothing, we can't erease the same field in all the data
			return false
		[false, true]:
			# erase the whole data
			return data.remove(key)
		[false, false]:
			# erase the field
			var obj = data.find(key)
			if obj:
				var f = obj.get(field, null)
				if typeof(f) == TYPE_ARRAY:
					f.erase(value)
					f.sort()
					return true
				else:
					return obj.erase(field)
			
	return false

class CSVData:
	var headers:Array = []
	
	var append:Array = []
	var merge:Array = []
	
	var data:Dictionary = {}
	
	var old_data:Dictionary = {}
	var game_data:Dictionary = {}
	
	var hashes:Dictionary = {}
	
	var paths:Dictionary = {}
	
	var KEY:String = ""
	var schema:Dictionary = {}
	
	var force_needs_save:bool = false
	
	func _init(paths:Dictionary, key:String):
		self.paths = paths
		KEY = key
		load_schema(paths.get("schema", ""))
		load_data(paths.get(Origin.GAME, ""), Origin.GAME)
		load_data(paths.get(Origin.APPEND, ""), Origin.APPEND)
		load_data(paths.get(Origin.MERGE, ""), Origin.MERGE)
		
		old_data = data.duplicate(true)
		
	func load_schema(path:String):
		var file = File.new()
		if file.open(path, File.READ) == OK:
			schema = parse_json(file.get_as_text())
			file.close()
		else:
			printerr("No schema loaded!!!")
	
	func load_data(path:String, origin:int):
		var file = File.new()
		if not file.file_exists(path):
			printerr("File %s doesn't exist" % path)
			return
			
		if file.open(path, File.READ) == OK:
			headers = Array(file.get_csv_line())
			var content = []
			while not file.eof_reached():
				content.push_back(Array(file.get_csv_line()))
				
			_content_to_data(content, origin)
			file.close()
		else:
			printerr("File %s can't be opened" % path)
		
	func _content_to_data(content, source):
		for c in content:
			if c.size() != headers.size(): continue
			var id = ""
			for i in headers.size():
				var h = headers[i]
				if h == KEY:
					id = c[i]
					data[id] = {}
					
				data[id][h] = _convert_from_csv(h, c[i])
				
			data[id]["__origin"] = source
			data[id]["__modified"] = false
			
			hashes[id] = data[id].hash()
			
			if source == Origin.GAME:
				game_data[id] = data[id].duplicate(true)
	
	func save_data():
		_save(paths.get(Origin.APPEND, ""), [Origin.APPEND])
		_save(paths.get(Origin.MERGE, ""), [Origin.MERGE, Origin.GAME])
		force_needs_save = false
		
	func _save(path, origins):
		var content = []
		for origin in origins:
			content += _data_to_content(origin)
		
		if not content or content.empty(): 
			var file = Directory.new()
			if file.file_exists(path):
				file.remove(path)
			print("No content for %s" % path)
			return false
			
		var dir = Directory.new()
		if not content or content.empty():
			if dir.file_exists(path):
				dir.remove(path)
			return false
		else:
			if not dir.file_exists(path):
				dir.make_dir_recursive(path.get_base_dir())
			
		var file = File.new()
		if file.open(path, File.WRITE) == OK:
			file.store_csv_line(PoolStringArray(headers))
			for entry in content:
				file.store_csv_line(PoolStringArray(entry))
				
			file.close()
			return true
		else:
			print("Couldn't save %s" % path)
			
		return false
		
	func _data_to_content(source):
		var subdata = []
		for key in data.keys():
			compare(key)
			var value = data[key]
			var origin = value.get("__origin", null)
			var save = false
			if origin == source:
				if origin == Origin.GAME:
					save = value.get("__modified", false)
					if save:
						value["__origin"] = Origin.MERGE
				else:
					save = true
			value["__modified"] = false
			if save:
				# TODO do this after knowing that the data has been saved correctly
				hashes[key] = value.hash()
				subdata.push_back(value)
		
		var values = []
		for entry in subdata:
			var csv = []
			for header in headers:
				csv.push_back(_convert_to_csv(header, entry[header]))
			values.push_back(csv)
		
		return values
		
	func create(key):
		data[key] = {}
		for i in headers.size():
			var h = headers[i]
			if h == KEY:
				data[key][h] = key
			else:
				var default = schema[h].get("default", "")
				if default is String and default == "":
					data[key][h] = _convert_from_csv(h, "")
				else:
					data[key][h] = default
			
		data[key]["__origin"] = Origin.APPEND
		data[key]["__modified"] = true
		hashes[key] = data[key].hash()
		
	func data_needs_save():
		if force_needs_save:
			return true
			
		if hashes.size() != data.size():
			return true
			
		for id in data:
			if not compare(id):
				return true
		return false
		
	"""
	Compares the entry with the saved hash
	Returns true if they are equals
	"""
	func compare(id):
		var entry = data.get(id, {})
		entry["__modified"] = false
		var modified = not entry.hash() == hashes.get(id, null)
		entry["__modified"] = modified
		return not modified
		
	func find(id):
		return data.get(id, null)
		
	func is_in_game_data(id:String):
		return game_data.has(id)
		
	func remove(id:String):
		if is_in_game_data(id):
			#don't delete it and revert it to old game data
			var default = game_data.get(id, {})
			for key in default.keys():
				data[id][key] = default.get(key)
				
			data[id]["__modified"] = false
			hashes[id] = data[id].hash()
			force_needs_save = true
			return true
		else:
			var result = data.erase(id)
			hashes.erase(id)
			# force the needs save because we removed the entry in both data and hashes and there's no way to know it
			force_needs_save = true
			return result
		
	func change_key(old_key:String, new_key:String):
		if old_key == new_key: return true
		
		var old = data.get(old_key, null)
		if old:
			var old_hash = hashes.get(old_key)
			hashes.erase(old_key)
			data.erase(old_key)
			old[KEY] = new_key
			data[new_key] = old
			hashes[new_key] = old_hash
			data[new_key]["__modified"] = true
			
			return true
		
		return false
	
	func _convert_from_csv(header:String, value:String):
		if not schema.has(header): return value
		
		match schema[header].type:
			"number":
				if value.empty():
					return float(0)
				else:
					return float(value)
			"point":
				if value.empty():
					return Vector2()
				else:
					var s = value.split("|")
					return Vector2(float(s[0]), float(s[1]))
			"list":
				if value.strip_edges().empty():
					return []
				else:
					var a = Array(value.split("|"))
					a.sort()
					return a
			"bool":
				if value.empty():
					return false
				else:
					return value.to_lower() == "yes"
			"empty_bool":
				if value.empty():
					return false
				else:
					return value.to_lower() == schema[header].get("on_true", "none")
			"script":
				return _convert_from_script(value)
			"text":
				return _convert_from_text(value)
			_:
				return value
				
	func _convert_from_text(value:String):
		var result = value
		result = result.replace("|", "\n")
		result = result.replace("[;]", ",")
		result = result.replace("~", '"')
		return result
		
	func _convert_from_script(value:String):
		var result = value
		result = result.replace("|", ",")
		result = result.replace("[;]", ",")
		result = result.replace("~", '"')
		result = result.replace("#", '||')
		result = beautify_code(result)
		return result
			
	func _convert_to_csv(header:String, value):
		if not schema.has(header): return value
			
		match schema[header].type:
			"number":
				if schema[header].has("empty_on"):
					var empty_on = schema[header].get("empty_on", null)
					if value == empty_on:
						return ""
						
				if value != null:
					return str(value)
				else:
					return ""
			"point":
				if value:
					return PoolStringArray([str(value.x), str(value.y)]).join("|")
				else:
					return "0|0"
			"list":
				if value:
					return PoolStringArray(value).join("|")
				else:
					return ""
			"bool":
				if value:
					return "YES"
				else:
					return "NO"
			"empty_bool":
				var on_true = schema[header].get("on_true", "none")
				var on_false = schema[header].get("on_false", "")
				if value:
					return on_true
				else:
					return on_false
			"script":
				return _convert_to_script(value)
			"text":
				return _convert_to_text(value)
			_:
				return value
	
	func _convert_to_text(value:String):
		var result = value
		result = result.replace("\n", "|")
		result = result.replace(",", "[;]")
		result = result.replace('"', "~")
		result = result.strip_edges()
		return result
		
	func _convert_to_script(value:String):
		var result = value
		result = result.replace("\n", " ")
		result = result.replace("\t", "") # remove tabs because it breaks the game
		result = result.replace(",", "[;]")
		result = result.replace('"', "~")
		result = result.strip_edges()
		return result
		
	# modification from https://notabug.org/Yeldham/json-beautifier-for-godot
	func beautify_code(json: String, spaces:=0) -> String:
		var indentation := ""
		if spaces > 0:
			for i in spaces:
				indentation += " "
		else:
			indentation = "\t"
		
		var quotation_start := -1
		var char_position := 0
		for i in json:
			# Avoid formating inside strings.
			if i == "\"":
				if quotation_start == -1:
					quotation_start = char_position
				elif json[char_position - 1] != "\\":
					quotation_start = -1
				
				char_position += 1
				
				continue
			elif quotation_start != -1:
				char_position += 1
				
				continue
			
			match i:
				# Remove pre-existing formating.
				"\n", "\t":
					json[char_position] = ""
					char_position -= 1
				
				"{":
					if json[char_position + 1] != "}":
						json = json.insert(char_position + 1, "\n")
						char_position += 1
				"}":
					if json[char_position - 1] != "{":
						json = json.insert(char_position, "\n")
						char_position += 1
				",":
					if json[char_position - 1] == " ":
						json[char_position - 1] = ""
						char_position -= 1
				";":
					json = json.insert(char_position + 1, "\n")
					char_position += 1
			
			char_position += 1
		
		# remove spaces at the beginning and end of the line and empty lines	
		var splits = json.split("\n")
		json = ""
		for split in splits:
			var s = split.strip_edges()
			if not s.empty():
				json += s + "\n"
		
		var bracket_start: int
		var bracket_end: int
		var bracket_count: int
		for i in [["{", "}"]]:
			bracket_start = json.find(i[0])
			while bracket_start != -1:
				bracket_end = json.find("\n", bracket_start)
				bracket_count = 0
				while bracket_end != - 1:
					if json[bracket_end - 1] == i[0]:
						bracket_count += 1
					elif json[bracket_end + 1] == i[1]:
						bracket_count -= 1
					
					# Move through the indentation to see if there is a match.
					while json[bracket_end + 1] == indentation:
						bracket_end += 1
						
						if json[bracket_end + 1] == i[1]:
							bracket_count -= 1
					
					if bracket_count <= 0:
						break
					
					bracket_end = json.find("\n", bracket_end + 1)
				
				# Skip one newline so the end bracket doesn't get indented.
				bracket_end = json.rfind("\n", json.rfind("\n", bracket_end) - 1)
				while bracket_end > bracket_start:
					json = json.insert(bracket_end + 1, indentation)
					bracket_end = json.rfind("\n", bracket_end - 1)
				
				bracket_start = json.find(i[0], bracket_start + 1)
		
		return json
