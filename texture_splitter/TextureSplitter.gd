extends PanelContainer

onready var OpenButton = find_node("OpenButton")
onready var SavePNGButton = find_node("SavePNGButton")
onready var SaveSplitButton = find_node("SaveSplitButton")
onready var MergePNGButton = find_node("MergePNGButton")

onready var PCKLabel = find_node("PCKLabel")
onready var SpriteList = find_node("SpriteList")
onready var TexturePanel = find_node("TexturePanel")
onready var SpriteTexture = find_node("SpriteTexture")
onready var SaveDialog = find_node("SaveDialog")

onready var WarningPopup = find_node("WarningPopup")

enum DialogMode {
	OpenPCK,
	MergePNG,
	SavePNG,
	SaveSplit,
}

var pck_opened = false setget _set_pck_opened
var sprites = []
var image_filename = null
var pck_size = Vector2()
var loaded_image:Image = null

var dialog_mode = DialogMode.OpenPCK

var premul_alpha_material = CanvasItemMaterial.new()

func _ready():
	SaveDialog.current_dir = "%s/data" % Settings.get_value(Settings.GAME_PATH)
	premul_alpha_material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	print(sprites)
	#parse_pck("res://assets/test/pack_1080.pck")
	#decode_image("res://assets/test/pack_1080.atf")
	#SpriteTexture.set_sprites(sprites)

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
	else:
		# TODO show warning
		self.pck_opened = false
		return

	SpriteList.clear()
	self.pck_opened = not sprites.empty() and image_filename != null
	if pck_opened:
		decode_image('%s/%s' % [path.get_base_dir(), image_filename])
		PCKLabel.text = path
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
	_make_dir(target.get_base_dir())
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
	s.material = premul_alpha_material
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

		s.material = premul_alpha_material

		viewport.add_child(s)

	_save_viewport(viewport, dest_file, true)

func merge_pngs(src:String):
	var target = src.plus_file("merged")
	var dir = Directory.new()
	if dir.open(src) == OK:
		var files_missing = []
		for sprite in sprites:
			var f = "%s/%s.png" % [src, sprite.name]
			if not dir.file_exists(f):
				files_missing.push_back('%s.png' % sprite.name)

		if not files_missing.empty():
			WarningPopup.window_title = "Files Missing!"
			WarningPopup.dialog_text = "The following files are missing:\n%s" % PoolStringArray(files_missing).join("\n")
			WarningPopup.popup_centered(Vector2(400, 100))
		else:
			save_sprites(src, target)
			WarningPopup.window_title = "File saved correctly!"
			WarningPopup.dialog_text = "File saved as 'merged.atf'"
			WarningPopup.popup_centered(Vector2(400, 100))

func _create_viewport(size):
	var viewport = Viewport.new()
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.hdr = false
	viewport.usage = Viewport.USAGE_2D
	viewport.size = size

	viewport.own_world = true
	viewport.world = World.new()
	viewport.world.environment = Environment.new()
	viewport.world.environment.background_mode = Environment.BG_COLOR
	viewport.world.environment.background_color = Color(1, 1, 1, 0)

	add_child(viewport)
	return viewport

func _save_viewport(viewport, target, compressed = false):
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var img:Image = viewport.get_texture().get_data()
	img.flip_y()
	#img.fix_alpha_edges()

	_make_dir(target.get_base_dir())

	if compressed:
		img.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_GENERIC, 1.0)

		var atf = AtfParser.new()
		atf.save(img.get_data(), viewport.size.x, viewport.size.y, "%s.atf" % target)
	else:
		img.save_png("%s.png" % target)

	viewport.queue_free()
	remove_child(viewport)

func _make_dir(dir:String):
	var d = Directory.new()
	d.make_dir_recursive(dir)

func _on_OpenButton_pressed():
	SaveDialog.mode = FileDialog.MODE_OPEN_FILE
	SaveDialog.filters = PoolStringArray(["*.pck"])
	dialog_mode = DialogMode.OpenPCK
	SaveDialog.popup_centered()

func _on_SavePNGButton_pressed():
	if not pck_opened: return
	SaveDialog.mode = FileDialog.MODE_SAVE_FILE
	SaveDialog.filters = PoolStringArray(["*.png"])
	dialog_mode = DialogMode.SavePNG
	SaveDialog.popup_centered()

func _on_SaveSplitButton_pressed():
	if not pck_opened: return
	SaveDialog.mode = FileDialog.MODE_OPEN_DIR
	SaveDialog.filters = PoolStringArray()
	dialog_mode = DialogMode.SaveSplit
	SaveDialog.popup_centered()

func _on_MergePNGButton_pressed():
	if sprites.empty(): return
	SaveDialog.mode = FileDialog.MODE_OPEN_DIR
	SaveDialog.filters = PoolStringArray()
	dialog_mode = DialogMode.MergePNG
	SaveDialog.popup_centered()

func _on_SaveDialog_dir_selected(dir):
	if not loaded_image: return
	match dialog_mode:
		DialogMode.SaveSplit:
			for sprite in sprites:
				if sprite.rotated:
					save_sprite_rotated(sprite, dir)
				else:
					save_sprite(sprite, dir)
		DialogMode.MergePNG:
			merge_pngs(dir)

func _on_SaveDialog_file_selected(path):
	match dialog_mode:
		DialogMode.OpenPCK:
			parse_pck(path)
		DialogMode.SavePNG:
			loaded_image.save_png(path)

func _set_pck_opened(value):
	pck_opened = value
	if pck_opened:
		SavePNGButton.disabled = false
		SaveSplitButton.disabled = false
		MergePNGButton.disabled = false
	else:
		SavePNGButton.disabled = true
		SaveSplitButton.disabled = true
		MergePNGButton.disabled = true
