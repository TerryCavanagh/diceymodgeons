extends PanelContainer

onready var Title = find_node("Title")
onready var DescriptionContainer = find_node("DescriptionContainer")
onready var Description = find_node("Description")

const brackets_regex = "(\\[(.*?)\\])"
const arrows_regex = "(<(.+)>)"

var card_size = 1

func _ready():
	change_size(1)
	
func change_color(color:String, category:String, upgraded:bool = false):
	if color.empty():
		# get the category color
		color = Gamedata.items.get("categories", {}).get(category, {}).get("color", "GRAY")
		
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
	title = Utils.humanize_equipment_name(title)
	Title.text = title.to_upper()
	Title.rect_scale = Vector2(0.8, 0.8)
	
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
			var n = Gamedata.symbols.get(s).get("image_name", s)
			result += "[img]res://assets/symbols/%s.png[/img]" % n
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
	
	_update_description_position()

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
		
	_update_description_position()

func _update_description_position():
	yield(get_tree(), "idle_frame")
	Description.rect_position.y = (Description.get_line_count() - 1) * -64
	if card_size == 2:
		Description.rect_position.y += 100
	Description.rect_pivot_offset = Description.rect_size / 2.0
	Description.rect_scale = Vector2(0.8, 0.8)

func _on_VBoxContainer_sort_children():
	Description.rect_scale = Vector2(0.8, 0.8)
	Title.rect_scale = Vector2(0.8, 0.8)
