extends Node

signal symbols_loaded()

func generate(mod_id:String):
	# load symbols.png and symbols.csv from mod or game
	# if any of the hashes don't match:
	#   generate mod folder in user data and generate symbols from the values in the csv and png
	# create mod entry in settings to save hash of csv and png
	# save dictionary in Gamedata.symbols with the new symbols
	var all_symbols = Database.read(Database.Table.SYMBOLS)
	var symbols = {}

	var path = "user://%s/symbols" % mod_id

	for key in all_symbols.keys():
		var symbol = all_symbols.get(key)
		if symbol.get("Type", "") == "SYMBOLTILE":

			var image_name = key.sha256_text()

			symbols[key] = {
				"tile": int(symbol.get("Value", "0")),
				"color": symbol.get("Colour", "0xffffff"),
				"name": key,
				"path": "%s/%s.res" % [path, image_name],
				"path_small": "%s/small/%s.res" % [path, image_name],
				"image_name": image_name
			}

	Gamedata.symbols = symbols

	var symbols_file = ModFiles.get_file('data/graphics/ui/symbols.png')

	var old_hash = Settings.get_symbols_hash(mod_id)
	var current_hash = File.new().get_sha256(symbols_file.path)

	var skip_generation = true

	if old_hash == current_hash:
		print("Found same hash")
		var file = File.new()
		for key in symbols.keys():
			var symbol = symbols.get(key)
			if not file.file_exists(symbol.get("path")) or not file.file_exists(symbol.get("path_small")):
				skip_generation = false
				break
	else:
		skip_generation = false

	if skip_generation:
		print("No need to generate a symbols cache")
		# No need to generate anything
		emit_signal("symbols_loaded")
		return

	var symbols_img = Image.new()
	if symbols_img.load(symbols_file.path) == OK:

		print("Generating symbols cache")

		Settings.set_symbols_hash(mod_id, current_hash)

		var sym_size = 90

		var dir = Directory.new()

		if dir.make_dir_recursive("%s/small/" % path) == OK:
			print("\tDirectories created at %s" % path)

		var symbols_array= []
		for i in range(0, symbols_img.get_width(), sym_size):
			var img = Image.new()
			img.create(sym_size, sym_size, false, symbols_img.get_format())
			img.blit_rect(symbols_img, Rect2(i, 0, sym_size, sym_size), Vector2())
			symbols_array.push_back(img)

		for symbol in symbols.keys():
			var data = symbols[symbol]
			var idx = data.get("tile", 0)
			var name = data.get("image_name", symbol)

			var img = symbols_array[idx]

			var texture = ImageTexture.new()
			texture.create_from_image(img, img.get_format())
			texture.flags = 0
			ResourceSaver.save(data.get("path"), texture, ResourceSaver.FLAG_COMPRESS)

			var small = Image.new()
			small.create(sym_size, sym_size, false, img.get_format())
			small.blit_rect(img, Rect2(0, 0, sym_size, sym_size), Vector2())
			small.resize(24, 24, Image.INTERPOLATE_LANCZOS)

			var small_texture = ImageTexture.new()
			small_texture.create_from_image(small, small.get_format())
			small_texture.flags = 0
			ResourceSaver.save(data.get("path_small"), small_texture, ResourceSaver.FLAG_COMPRESS)

	emit_signal("symbols_loaded")
