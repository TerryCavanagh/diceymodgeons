extends ConfirmationDialog

signal action_chosen(result)

enum {
	OKAY,
	CANCEL,
	OTHER,
}

onready var ok_button = get_ok()
onready var cancel_button = get_cancel()
onready var other_button = add_button("", true)

func _ready():
	ok_button.connect("pressed", self, "_on_button_pressed", [OKAY])
	cancel_button.connect("pressed", self, "_on_button_pressed", [CANCEL])
	other_button.connect("pressed", self, "_on_button_pressed", [OTHER])
	ok_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	other_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box = (ok_button.get_parent() as HBoxContainer)
	box.add_constant_override("separation", 16)
	box.alignment = BoxContainer.ALIGN_CENTER
	for child in box.get_children():
		if not child is Button:
			child.queue_free()
			
	get_close_button().connect("pressed", self, "_on_button_pressed", [CANCEL])
	
	var label = get_label()
	label.align = Label.ALIGN_CENTER
	
func _popup(text:String, title:String):
	window_title = title
	dialog_text = text
	rect_size = rect_min_size
	call_deferred("popup_centered_minsize", rect_min_size)
	
func popup_confirm(text:String, title:String = ""):
	if title.empty():
			title = "Please confirm..."
	
	
	ok_button.visible = true
	cancel_button.visible = true
	other_button.visible = false
	ok_button.text = "OK"
	
	_popup(text, title)
	
func popup_save(text:String, title:String = ""):
	if title.empty():
			title = "Confirm save..."
	
	ok_button.visible = true
	cancel_button.visible = true
	other_button.visible = true
	ok_button.text = "Save"
	other_button.text = "Don't save"
	
	_popup(text, title)

func popup_accept(text:String, title:String = ""):
	if title.empty():
			title = "Warning!"
	
	ok_button.visible = true
	cancel_button.visible = false
	other_button.visible = false
	ok_button.text = "OK"
	
	_popup(text, title)
	
func _on_button_pressed(result):
	emit_signal("action_chosen", result)
	hide()
