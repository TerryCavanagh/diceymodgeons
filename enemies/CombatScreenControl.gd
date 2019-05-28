extends Control

signal position_changed(new_position, target)
signal image_changed(image, path, target) 

var starting_position = Vector2(2497, 5)

var sprite_placeholder = preload("res://assets/garfield.png")
var overworld_sprite_placeholder = preload("res://assets/garfield_overworld.png")

func _ready():
	set_sprite(null, Vector2(), false)
	set_overworld_sprite(null, Vector2(), false)
	
func reset():
	$EnemyPos/Enemy.rect_position = Vector2()
	$Overworld/EnemyOverworld.rect_position = Vector2()
	
func set_sprite(texture:Texture, offset:Vector2, hd:bool = true):
	if not texture:
		texture = sprite_placeholder
		
	$EnemyPos/Enemy.rect_position = Vector2()
	$EnemyPos/Enemy.texture = texture
	
	if hd:
		$EnemyPos/Enemy.rect_scale = Vector2(1, 1)
	else:
		$EnemyPos/Enemy.rect_scale = Vector2(2, 2)
	
	var size = texture.get_size() * $EnemyPos/Enemy.rect_scale
	
	var relative = Vector2()
	var s = 672 * 2
	if size.x < s:
		relative.x = s - size.x
	
	$EnemyPos.rect_position = starting_position + relative
	$EnemyPos/Enemy.rect_position = offset
	
func set_overworld_sprite(texture:Texture, offset:Vector2, hd:bool = true):
	if not texture:
		texture = overworld_sprite_placeholder
	# TODO
	$Overworld/EnemyOverworld.texture = texture
	$Overworld/EnemyOverworld.rect_position = offset
	

func _on_Enemy_position_changed(new_position):
	emit_signal("position_changed", new_position, "enemy")

func _on_EnemyOverworld_position_changed(new_position):
	emit_signal("position_changed", new_position, "overworld")
