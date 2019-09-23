extends PanelContainer

onready var OpenButton = find_node("OpenButton")
onready var SavePNGButton = find_node("SavePNGButton")
onready var SpriteList = find_node("SpriteList")
onready var TexturePanel = find_node("TexturePanel")
onready var SpriteTexture = find_node("SpriteTexture")
onready var SaveDialog = find_node("SaveDialog")

enum DialogMode {
	OpenPCK,
	MergePNG,
	SavePNG,
	SaveSplit,
}

var sprites = []
var image_filename = null
var pck_size = Vector2()
var loaded_image:Image = null

var dialog_mode = DialogMode.OpenPCK

func _ready():
	print(sprites)
	parse_pck("res://assets/test/pack_1080.pck")
	decode_image("res://assets/test/pack_1080.atf")
	SpriteTexture.set_sprites(sprites)
	
func parse_pck(path):
	sprites = []
	image_filename = null
	var pck = XMLParser.new()
	if pck.open(path) == OK:
		while pck.read() == OK:
			match pck.get_node_type():
				XMLParser.NODE_ELEMENT:
					match pck.get_node_name():
						"TextureAtlas":
							image_filename = pck.get_named_attribute_value_safe("imagePath")
							var w = pck.get_named_attribute_value_safe("width").to_int()
							var h = pck.get_named_attribute_value_safe("height").to_int()
							pck_size = Vector2(w, h)
						"SubTexture":
							var n = pck.get_named_attribute_value_safe("name")
							var x = pck.get_named_attribute_value_safe("x").to_int()
							var y = pck.get_named_attribute_value_safe("y").to_int()
							var w = pck.get_named_attribute_value_safe("width").to_int()
							var h = pck.get_named_attribute_value_safe("height").to_int()
							var r = pck.get_named_attribute_value_safe("rotated") == "true"
							sprites.push_back({
								"name": n,
								"rect": Rect2(x, y, w, h),
								"rotated": r
							})
							
	SpriteList.clear()
	for sprite in sprites:
		SpriteList.add_item(sprite.get("name", "Unknown"))
	
func decode_image(path):
	var file = File.new()
	if file.open(path, File.READ) == OK:
		var atf = AtfParser.new()
		loaded_image = atf.parse(file)
		if loaded_image:
			if not loaded_image.decompress() == OK:
				print('Image could not be decompress')
			var tex = ImageTexture.new()
			tex.create_from_image(loaded_image)
			SpriteTexture.texture = tex
		file.close()
	else:
		print('Cannot open file')
		
func save_sprite(sprite, dir):
	var img = Image.new()
	img.create(sprite.rect.size.x, sprite.rect.size.y, false, loaded_image.get_format())
	img.blit_rect(loaded_image, sprite.rect, Vector2())
	var target = '%s/%s.png' % [dir, sprite.name]
	print('%s => %s' % [sprite, target])
	img.save_png(target)
	
func save_sprite_rotated(sprite, dir):
	var viewport = _create_viewport(Vector2(sprite.rect.size.y, sprite.rect.size.x))
	
	var s = Sprite.new()
	s.centered = true
	s.texture = SpriteTexture.texture
	s.region_enabled = true
	s.region_rect = sprite.rect
	s.rotation_degrees = 270
	s.position = Vector2(sprite.rect.size.y / 2.0, sprite.rect.size.x / 2.0)
	viewport.add_child(s)
	
	var target = '%s/%s' % [dir, sprite.name]
	print('%s => %s' % [sprite, target])
	_save_viewport(viewport, target)

	
func save_sprites(src_dir, dest_file):
	var viewport = _create_viewport(pck_size)
	
	for sprite in sprites:
		var img = Image.new()
		img.load('%s/%s.png' % [src_dir, sprite.name])
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		
		var s = Sprite.new()
		s.texture = tex
		s.position = sprite.rect.position + sprite.rect.size / 2.0
		if sprite.rotated:
			s.rotation_degrees = 270
			s.flip_v = true
			s.flip_h = true
		viewport.add_child(s)
		
	_save_viewport(viewport, dest_file, true)
	
	
func _create_viewport(size):
	var viewport = Viewport.new()
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.render_target_v_flip = true
	viewport.usage = Viewport.USAGE_2D
	viewport.size = size
	add_child(viewport)
	return viewport
	
func _save_viewport(viewport, target, compressed = false):
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var img = viewport.get_texture().get_data()
	if compressed:
		img.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_GENERIC, 1.0)
		print(img.get_format())
		var atf = AtfParser.new()
		atf.save(img.get_data(), viewport.size.x, viewport.size.y, "%s.atf" % target)
	else:
		img.save_png("%s.png" % target)
	
	viewport.queue_free()
	remove_child(viewport)
	
func _on_SavePNGButton_pressed():
	if not loaded_image: return
	loaded_image.save_png("res://assets/test/pack_1080.png")

func _on_SaveSplitButton_pressed():
	SaveDialog.mode = FileDialog.MODE_OPEN_DIR
	dialog_mode = DialogMode.SaveSplit
	SaveDialog.popup_centered()
	
func _on_MergePNGButton_pressed():
	save_sprites("res://test/test_img", "res://test/test_img/__merged")

func _on_SaveDialog_dir_selected(dir):
	if not loaded_image: return
	match dialog_mode:
		DialogMode.SaveSplit:
			for sprite in sprites:
				if sprite.rotated:
					var w = save_sprite_rotated(sprite, dir)
				else:
					save_sprite(sprite, dir)

func _on_SaveDialog_file_selected(path):
	pass # Replace with function body.
