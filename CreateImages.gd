tool
extends EditorScript

func _run():
	_prepare_images()

func _prepare_images():
	var delete_img = preload("res://assets/trashcanOpen.png")
	delete_img.resize(24, 24, Image.INTERPOLATE_LANCZOS)
	
	delete_img.save_png("res://assets/trascanOpen_24.png")
	
	var return_img = preload("res://assets/return.png")
	return_img.resize(24, 24, Image.INTERPOLATE_LANCZOS)
	
	return_img.save_png("res://assets/return_24.png")
	
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
		symbols_array[idx].save_png("res://assets/symbols/%s.png" % symbol)