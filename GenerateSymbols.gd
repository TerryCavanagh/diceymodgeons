extends Node

signal symbols_loaded()

const DEFAULT_SYMBOLS_KEY = "__default_symbols__"
const SYMBOL_SIZE = 90
const SMALL_SYMBOL_SIZE = 24

var user_path = "user://"

func generate(mod_id:String):
	# load symbols.png and symbols.csv from mod or game
	# if any of the hashes don't match:
	#   generate mod folder in user data and generate symbols from the values in the csv and png
	# create mod entry in settings to save hash of csv and png
	# save dictionary in Gamedata.symbols with the new symbols
	var all_symbols = Database.read(Database.Table.SYMBOLS)
	var symbols = {}

	user_path = "user://%s/symbols" % mod_id

	var files_to_load = {DEFAULT_SYMBOLS_KEY: 'data/graphics/ui/symbols.png'}


	for key in all_symbols.keys():
		var symbol = all_symbols.get(key)
		match symbol.get("Type", ""):
			"SYMBOLTILE":
				var image_name = key.sha256_text()

				symbols[key] = {
					"tile": int(symbol.get("Value", "0")),
					"color": symbol.get("Colour", "0xffffff"),
					"name": key,
					"path": "%s/%s.res" % [user_path, image_name],
					"path_small": "%s/small/%s.res" % [user_path, image_name],
					"image_name": image_name
				}
			"IMAGE":
				var image_name = key.sha256_text()
				symbols[key] = {
					"source": symbol.get("Value", ""),
					"color": symbol.get("Colour", "0xffffff"),
					"name": key,
					"path": "%s/%s.res" % [user_path, image_name],
					"path_small": "%s/small/%s.res" % [user_path, image_name],
					"image_name": image_name
				}

				files_to_load[key] = 'data/graphics/%s.png' % symbols[key].get("source", "")

	Gamedata.symbols = symbols

	var filepaths = {}
	var hashes = {}
	for key in files_to_load:
		var file = ModFiles.get_file(files_to_load[key])
		if file:
			filepaths[key] = file.path
			hashes[key] = File.new().get_sha256(file.path)
		else:
			print("Symbol %s not found in %s" % [key, files_to_load[key]])

	var saved_hashes = Settings.get_symbols_hash(mod_id)

	var skip_generation = true
	if not typeof(saved_hashes) == TYPE_DICTIONARY:
		skip_generation = false
	elif not hashes.hash() == saved_hashes.hash():
		for key in hashes:
			if not saved_hashes.has(key):
				skip_generation = false
				break

			if not hashes[key] == saved_hashes[key]:
				skip_generation = false
				break

	if skip_generation:
		var test_file = File.new()
		for key in symbols:
			var symbol = symbols[key]
			if not test_file.file_exists(symbol.get("path", "")) or not test_file.file_exists(symbol.get("path_small", "")):
				skip_generation = false
				break

	Settings.set_symbols_hash(mod_id, hashes)

	if skip_generation:
		print("No need to generate a symbols cache")
		emit_signal("symbols_loaded")
		return

	print("Generating symbols cache")

	var dir = Directory.new()
	if dir.make_dir_recursive("%s/small/" % user_path) == OK:
		print("\tDirectories created at %s" % user_path)

	for key in filepaths:
		var filepath = filepaths[key]
		if key == DEFAULT_SYMBOLS_KEY:
			_generate_tile_symbols(filepath, symbols)
		else:
			_generate_image_symbol(filepath, symbols[key])

	emit_signal("symbols_loaded")

func _generate_tile_symbols(path, symbols):
	var symbols_img = Image.new()
	if symbols_img.load(path) == OK:

		var symbols_array= []
		for i in range(0, symbols_img.get_width(), SYMBOL_SIZE):
			var img = Image.new()
			img.create(SYMBOL_SIZE, SYMBOL_SIZE, false, symbols_img.get_format())
			img.blit_rect(symbols_img, Rect2(i, 0, SYMBOL_SIZE, SYMBOL_SIZE), Vector2())
			symbols_array.push_back(img)

		for symbol in symbols.keys():
			var data = symbols[symbol]
			if data.has("source"):
				# this is an image symbol, skip
				continue
			var idx = data.get("tile", 0)

			var img = symbols_array[idx]

			_generate_images(img, data)

func _generate_image_symbol(path, symbol):
	var original_img = Image.new()
	if original_img.load(path) == OK:
		var img = original_img
		if not original_img.get_size() == Vector2(SYMBOL_SIZE, SYMBOL_SIZE):
			img.resize(SYMBOL_SIZE, SYMBOL_SIZE, Image.INTERPOLATE_LANCZOS)

		_generate_images(img, symbol)

func _generate_images(img, data):
	var texture = ImageTexture.new()
	texture.create_from_image(img, img.get_format())
	texture.flags = 0
	ResourceSaver.save(data.get("path"), texture, ResourceSaver.FLAG_COMPRESS)

	var small = Image.new()
	small.create(SYMBOL_SIZE, SYMBOL_SIZE, false, img.get_format())
	small.blit_rect(img, Rect2(0, 0, SYMBOL_SIZE, SYMBOL_SIZE), Vector2())
	small.resize(SMALL_SYMBOL_SIZE, SMALL_SYMBOL_SIZE, Image.INTERPOLATE_LANCZOS)

	var small_texture = ImageTexture.new()
	small_texture.create_from_image(small, small.get_format())
	small_texture.flags = 0
	ResourceSaver.save(data.get("path_small"), small_texture, ResourceSaver.FLAG_COMPRESS)
