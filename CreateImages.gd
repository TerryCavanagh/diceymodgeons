tool
extends EditorScript

func _run():
	_prepare_images()

func _prepare_images():
	var delete_img = preload("res://assets/trashcanOpen.png")
	delete_img.resize(20, 20, Image.INTERPOLATE_LANCZOS)

	delete_img.save_png("res://assets/trascanOpen_20.png")

	var return_img = preload("res://assets/return.png")
	return_img.resize(20, 20, Image.INTERPOLATE_LANCZOS)

	return_img.save_png("res://assets/return_20.png")

