extends Node

signal data_changed(table, key, equals)

var mod_path:String = ""

var _fighters:CSVData = null
var _equipment:CSVData = null

enum {CREATE,READ,UPDATE,DELETE}

enum Table {
	FIGHTERS,
	EQUIPMENT,
}

var undo_redo = UndoRedo.new()

func _init():
	load_data()
	
func load_data():
	_fighters = CSVData.new("res://data/text/fighters.csv", "res://data/text/fighters_schema.json", "Name")
	_equipment = CSVData.new("res://data/text/equipment.csv", "res://data/text/equipment_schema.json", "Name")
	
func save_data():
	pass
	
func commit(table:int, action:int, key = null, field = null, value = null):
	"""
	Makes a database commit.
	- table: The database table
	- action: The action (CREATE, READ, UPDATE, DELETE)
	- field: The field
	- Value: The value
	"""
	var data = null
	match table:
		Table.FIGHTERS:
			data = _fighters
		Table.EQUIPMENT:
			data = _equipment
			
	if not data:
		return null
		
	var result = null
	match action:
		CREATE:
			print_debug("CREATE %s: %s (%s) = %s" % [table, key, field, value])
			result = _create(data, key, field, value)
		READ:
			print_debug("READ %s: %s (%s) = %s" % [table, key, field, value])
			result = _read(data, key, field)
		UPDATE:
			print_debug("UPDATE %s: %s (%s) = %s" % [table, key, field, value])
			result = _update(data, key, field, value)
		DELETE:
			print_debug("DELETE %s: %s (%s) = %s" % [table, key, field, value])
			result = _delete(data, key, field, value)
		
	if not action == READ:
		emit_signal("data_changed", table, key, data.compare(key))
		
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
				data.data[key] = {}
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
			var obj = data.find(key)
			if obj:
				# remove it from data, and add it back with the new key
				data.data.erase(key)
				data.data[value] = obj
				return true
				
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
			return data.data.erase(key)
		[false, false]:
			# erase the field
			var obj = data.find(key)
			if obj:
				var f = obj.get(field, null)
				if typeof(f) == TYPE_ARRAY:
					var r = f.erase(value)
					f.sort()
					return r
				else:
					return obj.erase(field)
			
	return false

class CSVData:
	var headers:Array = []
	var content:Array = []
	
	var append:Array = []
	var merge:Array = []
	
	var data:Dictionary = {}
	var original_data:Dictionary = {}
	var hashes:Dictionary = {}
	
	var path:String
	
	var KEY:String = ""
	var schema:Dictionary = {}
	
	func _init(path:String, schema:String, key:String):
		self.path = path
		load_schema(schema)
		load_data(path, key)
		
	func load_schema(path:String):
		var file = File.new()
		if file.open(path, File.READ) == OK:
			schema = parse_json(file.get_as_text())
			file.close()
		else:
			printerr("No schema loaded!!!")
	
	func load_data(path:String, key:String):
		KEY = key
		var file = File.new()
		if file.open(path, File.READ) == OK:
			headers = Array(file.get_csv_line())
			while not file.eof_reached():
				content.push_back(Array(file.get_csv_line()))
				
			file.close()
		else:
			printerr("File %s can't be opened" % path)
			
		for c in content:
			if c.size() != headers.size(): continue
			var id = ""
			for i in headers.size():
				var h = headers[i]
				if h == KEY:
					id = c[i]
					data[id] = {}
					
				data[id][h] = _convert_from_csv(h, c[i])
				
			data[id]["__from"] = "content"
			
			hashes[id] = data[id].hash()
			
		original_data = data.duplicate(true)
		
	
	func save_data(path:String):
		pass
		
	func compare(id):
		return  data.get(id, {}).hash() == hashes.get(id, null)
		
	func find(id):
		return data.get(id, null)
		
	func remove(id:String):
		return data.erase(id)
	
	func _convert_from_csv(header:String, value:String):
		if not schema.has(header): return value
		
		match schema[header]:
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
				if value.empty():
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
		result = beautify_code(result)
		return result
		
	func _convert_to_csv(data):
		pass
	
	func _convert_to_text(value:String):
		# TODO
		return value
		
	func _convert_to_script(value:String):
		# TODO
		return value
		
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