extends WindowDialog

func _ready():
	rect_size = $VBoxContainer.rect_size + Vector2(16, 16)

func _on_OKButton_pressed():
	hide()

func _on_DontShowCheck_toggled(button_pressed):
	Settings.set_value(Settings.DONT_SHOW_WARNINGS, button_pressed)
