extends PanelContainer


signal create_pressed()
signal load_pressed()


func _on_CreateButton_pressed():
	emit_signal("create_pressed")

func _on_LoadButton_pressed():
	emit_signal("load_pressed")
