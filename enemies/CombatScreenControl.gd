extends Control

signal position_changed(new_position, target)
signal image_changed(image, path, target) 

onready var EnemyPos = find_node("EnemyPos")
onready var Enemy = find_node("Enemy")
onready var Overworld = find_node("Overworld")
onready var EnemyOverworld = find_node("EnemyOverworld")

var starting_position = Vector2(2497, 5)

var sprite_placeholder = preload("res://assets/garfield.png")
var overworld_sprite_placeholder = preload("res://assets/garfield_overworld.png")

func _ready():
	set_sprite(null, Vector2(), false)
	set_overworld_sprite(null, Vector2(), false)
	
func reset():
	Enemy.rect_position = Vector2()
	EnemyOverworld.rect_position = Vector2()
	
func set_sprite(texture:Texture, offset:Vector2, hd:bool = true):
	if not texture:
		texture = sprite_placeholder
		
	Enemy.rect_position = Vector2()
	Enemy.texture = texture
	
	if hd:
		Enemy.rect_scale = Vector2(1, 1)
	else:
		Enemy.rect_scale = Vector2(2, 2)
	
	var size = texture.get_size() * Enemy.rect_scale
	
	var relative = Vector2()
	var s = 672 * 2
	if size.x < s:
		relative.x = s - size.x
	
	EnemyPos.rect_position = starting_position + relative
	Enemy.rect_position = offset
	
func set_overworld_sprite(texture:Texture, offset:Vector2, hd:bool = true):
	if not texture:
		texture = overworld_sprite_placeholder
	# TODO
	EnemyOverworld.texture = texture
	EnemyOverworld.rect_position = offset
	

func _on_Enemy_position_changed(new_position):
	emit_signal("position_changed", new_position, "enemy")

func _on_EnemyOverworld_position_changed(new_position):
	emit_signal("position_changed", new_position, "overworld")
