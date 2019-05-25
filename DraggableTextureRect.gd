extends TextureRect

signal position_changed(new_position)

var dragging = false
var drag_mouse_position = Vector2()

func _ready():
	pass

func _draw():
	if not texture: return
	var color = Color.blue
	color.a = 0.2 if dragging else 0

	draw_rect(Rect2(0, 0, texture.get_width(), texture.get_height()), color, true)

func _gui_input(event):
	if not event is InputEventMouse: return

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		dragging = event.is_pressed()
		if dragging:
			drag_mouse_position = event.global_position
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			update()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.warp_mouse_position(drag_mouse_position)
			update()
			return

	if not dragging: return

	if event is InputEventMouseMotion:
		rect_position += event.relative * get_global_transform().get_scale()
		rect_position = rect_position.floor()
		emit_signal("position_changed", rect_position)

