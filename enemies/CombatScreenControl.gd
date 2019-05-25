extends Control

var starting_position = Vector2(2497, 5)

func _ready():
	set_sprite(preload("res://assets/garfield.png"), false)
	set_overworld_sprite(preload("res://assets/garfield_overworld.png"), false)
	
func set_sprite(texture:Texture, hd:bool = true):
	$EnemyPos/Enemy.rect_position = Vector2()
	$EnemyPos/Enemy.texture = texture
	
	var offset = Vector2()
	
	if hd:
		$EnemyPos/Enemy.rect_scale = Vector2(1, 1)
	else:
		$EnemyPos/Enemy.rect_scale = Vector2(2, 2)
	
	var size = texture.get_size() * $EnemyPos/Enemy.rect_scale
	
	var s = 672 * 2
	if size.x < s:
		offset.x = s - size.x
	
	$EnemyPos.rect_position = starting_position + offset
	
func set_overworld_sprite(texture:Texture, hd:bool = true):
	$Overworld/EnemyOverworld.rect_position = Vector2()
	$Overworld/EnemyOverworld.texture = texture

func _on_Enemy_position_changed(new_position):
	print('Enemy pos: %s' % new_position)

func _on_EnemyOverworld_position_changed(new_position):
	print('EnemyOverworld pos: %s' % new_position)
