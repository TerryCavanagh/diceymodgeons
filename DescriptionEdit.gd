extends HBoxContainer

signal text_changed()

onready var TextEdit = find_node("TextEdit")
onready var Symbols = find_node("Symbols")

var text = "" setget _set_text, _get_text

func _ready():

	GenerateSymbols.connect("symbols_loaded", self, "_on_symbols_loaded")
	TextEdit.text = text

func _set_text(value):
	text = value
	if not TextEdit: return
	TextEdit.text = value

func _get_text():
	if not TextEdit: return text
	return TextEdit.text

func _on_TextEdit_text_changed():
	emit_signal("text_changed")


func _on_TextureButton_pressed(symbol):
	# TODO remove this hardcoded thing
	var t = ""
	if symbol == "d6":
		t = "<%s>" % symbol
	else:
		t = "[%s]" % symbol
	TextEdit.insert_text_at_cursor(t)

func _on_symbols_loaded():
	for button in Symbols.get_children():
		Symbols.remove_child(button)
		button.queue_free()

	for symbol in Gamedata.symbols.keys():
		var data = Gamedata.symbols[symbol]
		var button = TextureButton.new()
		var path = Gamedata.symbols.get(symbol).get("path", null)
		var texture = load(path)
		button.texture_normal = texture
		button.hint_tooltip = symbol
		button.expand = true
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.rect_min_size = Vector2(50, 50)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.connect("pressed", self, "_on_TextureButton_pressed", [symbol])
		Symbols.add_child(button)
