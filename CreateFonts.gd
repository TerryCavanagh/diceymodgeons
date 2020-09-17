tool
extends EditorScript

func _run():
	var fonts = [
	"londrinasolid_90",
	"londrinasolid_72",
	"pangolin_72",
	"pangolin_90"
	]

	for font in fonts:
		var fnt = _parse_font("res://assets/game_fonts/%s.xml" % font)
		if fnt:
			ResourceSaver.save("res://assets/game_fonts/%s.tres" % font, fnt)

func _parse_font(path:String):
	var xml = XMLParser.new()
	if xml.open(path) != OK:
		print("Couldn't open the xml " + path)
		return null

	var font = BitmapFont.new()
	var i = 0
	while xml.read() == OK:
		match xml.get_node_type():
			XMLParser.NODE_ELEMENT:
				match xml.get_node_name():
					"common":
						font.height = xml.get_named_attribute_value("lineHeight").to_float()
						font.ascent = xml.get_named_attribute_value("base").to_float()
					"page":
						var tex_path = xml.get_named_attribute_value("file")
						tex_path = path.get_base_dir() + "/" + tex_path

						font.add_texture(load(tex_path))
					"char":
						var id = xml.get_named_attribute_value("id").to_int()
						var x = xml.get_named_attribute_value("x").to_int()
						var y = xml.get_named_attribute_value("y").to_int()
						var w = xml.get_named_attribute_value("width").to_int()
						var h = xml.get_named_attribute_value("height").to_int()
						var xo = xml.get_named_attribute_value("xoffset").to_int()
						var yo = xml.get_named_attribute_value("yoffset").to_int()
						var adv = xml.get_named_attribute_value("xadvance").to_int()
						var tex = xml.get_named_attribute_value("page").to_int()

						font.add_char(id, tex, Rect2(x, y, w, h), Vector2(xo, yo), adv)
					"kerning":
						var f = xml.get_named_attribute_value("first").to_int()
						var s = xml.get_named_attribute_value("second").to_int()
						var a = xml.get_named_attribute_value("amount").to_int()

						font.add_kerning_pair(f, s, a)

	return font
