extends PanelContainer

signal text_changed(new_text)

onready var TextEdit = find_node("TextEdit")

export (String, MULTILINE) var text setget _set_text, _get_text
export (bool) var enable_highlighting = true setget _set_enable_highlighting

var completion_shortcut = ShortCut.new()

var haxe_keywords = ["abstract", "break", "case", "cast", "catch", "class", "continue", "default", "do", "dynamic", "else", "enum", "extends", "extern", "false", "for", "function", "if", "implements", "import", "in", "inline", "interface", "macro", "new", "null", "override", "package", "private", "public", "return", "static", "switch", "this", "throw", "true", "try", "typedef", "untyped", "using", "var", "while"]

var theme_color = {
	background_color="ff242424",
	completion_background_color="ff343434",
	completion_selected_color="ff464646",
	completion_existing_color="21dfdfdf",
	completion_scroll_color="ffffffff",
	completion_font_color="ffaaaaaa",
	caret_color="ffaaaaaa",
	caret_background_color="ff2c2c2c",
	line_number_color="ff666666",
	text_color="ffcccccc",
	text_selected_color="ffcccccc",
	keyword_color="ffcc8242",
	base_type_color="ffa5c261",
	engine_type_color="ffffc66d",
	function_color="ffffc66d",
	member_variable_color="ff9e7bb0",
	comment_color="ff707070",
	string_color="ff6a8759",
	number_color="ff7a9ec2",
	symbol_color="ffcccccc",
	selection_color="3000c3ff",
	brace_mismatch_color="ffff3333",
	current_line_color="0bffffff",
	line_length_guideline_color="ff333333",
	mark_color="38ff3232",
	breakpoint_color="33cccc66",
	code_folding_color="ff808080",
	word_highlighted_color="1400c2ff",
	search_result_color="ff653618",
	search_result_border_color="00000000"
}

func _ready():
	for key in theme_color.keys():
		TextEdit.add_color_override(key, Color(theme_color[key]))
	for keyword in haxe_keywords:
		TextEdit.add_keyword_color(keyword, Color(theme_color["keyword_color"]))

	TextEdit.syntax_highlighting = enable_highlighting

	"""
	for constant in Gamedata.scripts.constants:
		TextEdit.add_member_keyword(constant, Color(theme_color["string_color"]))

	TextEdit.set_completion(true, PoolStringArray([".", ",", "(", "="]))
	"""

	var key = InputEventKey.new()
	key.scancode = KEY_SPACE
	key.control = true
	completion_shortcut.shortcut = key

func _input(event):
	if not visible or not TextEdit.has_focus(): return
	if completion_shortcut.is_shortcut(event) and event.is_pressed() and not event.is_echo():
		print("query completion")
		#TextEdit.emit_signal("completion_requested")
		get_tree().set_input_as_handled()

func _set_text(value):
	if not TextEdit: return
	TextEdit.text = value
	TextEdit.cursor_set_line(0)

func _get_text():
	if not TextEdit: return ""
	return TextEdit.text

func _set_enable_highlighting(value):
	enable_highlighting = value
	if TextEdit:
		TextEdit.syntax_highlighting = enable_highlighting

func _on_TextEdit_text_changed():
	emit_signal("text_changed", TextEdit.text)

func _on_TextEdit_completion_requested():
	print("completion requested")
	#TextEdit.code_complete(PoolStringArray(Gamedata.scripts.constants), true)

