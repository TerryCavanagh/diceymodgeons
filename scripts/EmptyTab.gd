extends PanelContainer

signal open_pressed()
signal copy_pressed()
signal create_pressed()

var path = ""

func _on_CreateButton_pressed():
	emit_signal("create_pressed")

func _on_OpenButton_pressed():
	emit_signal("open_pressed")

func _on_CopyButton_pressed():
	emit_signal("copy_pressed")
