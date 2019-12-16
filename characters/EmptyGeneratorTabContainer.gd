extends PanelContainer


signal create_pressed()


func _on_CreateButton_pressed():
	emit_signal("create_pressed")
