extends PanelContainer

onready var Title = find_node("Title")
onready var DescriptionContainer = find_node("DescriptionContainer")
onready var Description = find_node("Description")

const brackets_regex = "(\\[(.*?)\\])"
const arrows_regex = "(<(.+)>)"

var card_size = 1

func _ready():
	change_size(1)
	
func change_color(color:String, upgraded:bool = false):
	if color.empty():
		color = "grey"
	match color:
		"GRAY":
			color = "grey"
		"CYAN":
			color = "blue"
		"WHITE":
			color = "grey"
		"BRIGHTCYAN":
			color = "blue"
		"BLACK":
			color = "silence"
			
	var upgraded_name = "usmall" if upgraded else "small"
	var texture = "res://assets/panels/%s_%s.png" % [upgraded_name, color.to_lower()]
	var stylebox = get_stylebox("panel").duplicate()
	stylebox.texture = load(texture)
	add_stylebox_override("panel", stylebox)

func set_title(title:String):
	self_modulate.a = 1.0
	if title.findn("_weakened") > -1 or title.findn("_downgraded") > -1:
		self_modulate.a = 0.5
	title = title.replacen("_upgraded", "+")
	title = title.replacen("_weakened", "-")
	title = title.replacen("_downgraded", "-")
	Title.text = title
	
func set_description(desc:String):
	var regex = RegEx.new()
	regex.compile(brackets_regex)

	var matches = regex.search_all(desc)
	var result = ""
	var last = 0
	for m in matches:
		result += desc.substr(last, m.get_start() - last)
		last  = m.get_end()
		var s = m.get_string(2).strip_edges()
		if Gamedata.symbols.has(s):
			result += "[img]res://assets/symbols/%s.png[/img]" % s
		elif s.empty():
			result += "[img]res://assets/symbols/d6.png[/img]"
		elif s == "gray":
			pass
	result += desc.substr(last, desc.length() - last)
	
	result = result.replace("<d6>", "[img]res://assets/symbols/d6.png[/img]")
	
	regex.compile(arrows_regex)
	result = regex.sub(result, "[color=red]99[/color]", true)
	Description.clear()
	Description.bbcode_text = "[center]%s[/center]" % result
	
	yield(get_tree(), "idle_frame")
	Description.rect_position.y = (result.split("\n").size() - 1) * -42
	if card_size == 2:
		Description.rect_position.y += 150
	Description.rect_pivot_offset = Description.rect_size / 2.0
	Description.rect_scale = Vector2(0.85, 0.85)

func change_size(s):
	card_size = s
	if s == 1:
		rect_size = Vector2(792, 612)
		rect_pivot_offset = rect_size / 2.0
		margin_left = -rect_pivot_offset.x
		margin_right = rect_pivot_offset.x
		margin_top = -rect_pivot_offset.y
		margin_bottom = rect_pivot_offset.y
	elif s == 2:
		rect_size = Vector2(792, 900)
		rect_pivot_offset = rect_size / 2.0
		margin_left = -rect_pivot_offset.x
		margin_right = rect_pivot_offset.x
		margin_top = -rect_pivot_offset.y
		margin_bottom = rect_pivot_offset.y