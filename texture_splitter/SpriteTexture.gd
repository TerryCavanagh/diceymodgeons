extends TextureRect

var sprites = []

func _draw():
	return
	for sprite in sprites:
		draw_rect(sprite.rect, Color(1, 0, 0, 0.2), true)

func set_sprites(sprites):
	self.sprites = sprites
	update()


