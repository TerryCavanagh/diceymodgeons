tool
extends EditorScript

func _run():
	_prepare_images()

func _prepare_images():
	var delete_img = preload("res://assets/trashcanOpen.png")
	delete_img.resize(20, 20, Image.INTERPOLATE_LANCZOS)
	
	delete_img.save_png("res://assets/trascanOpen_20.png")
	
	var return_img = preload("res://assets/return.png")
	return_img.resize(20, 20, Image.INTERPOLATE_LANCZOS)
	
	return_img.save_png("res://assets/return_20.png")
	
	var symbols_img = preload("res://assets/symbols/symbols.png")
	
	var sym_size = 90
	
	var symbols_array= []
	for i in range(0, symbols_img.get_width(), sym_size):
		var img = Image.new()
		img.create(sym_size, sym_size, false, symbols_img.get_format())
		img.blit_rect(symbols_img, Rect2(i, 0, sym_size, sym_size), Vector2())
		symbols_array.push_back(img)
		
	for symbol in Gamedata.symbols.keys():
		var data = Gamedata.symbols[symbol]
		var idx = data.get("tile", 0)
		var name = data.get("image_name", symbol)
		symbols_array[idx].save_png("res://assets/symbols/%s.png" % name)
		
	for symbol in Gamedata.symbols.keys():
		var data = Gamedata.symbols[symbol]
		var idx = data.get("tile", 0)
		var name = data.get("image_name", symbol)
		var small = Image.new()
		small.create(sym_size, sym_size, false, symbols_array[idx].get_format())
		small.blit_rect(symbols_array[idx], Rect2(0, 0, sym_size, sym_size), Vector2())
		small.resize(24, 24, Image.INTERPOLATE_LANCZOS)
		small.save_png("res://assets/symbols/small/%s.png" % name)
	
