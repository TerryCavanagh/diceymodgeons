extends LineEdit

export (int, 0, 100) var max_values = 5

var list:Array = []

func _ready():
	pass
	
func _input(event):
	if not $Popup.visible: return
	if event is InputEventKey and event.is_pressed():
		if event.is_action("ui_up"):
			print("up")
			$Popup.grab_focus()
		elif event.is_action("ui_down"):
			print("down")
			$Popup.grab_focus()
			
			
func check_text():
	if list.find(text) == -1:
		add_color_override("font_color", Color.red)
	else:
		add_color_override("font_color", Color.green)
	
func _sort_similarities(a, b):
	return a.value > b.value

func _on_FuzzyLineEdit_text_changed(new_text):
	var similarities = []
	var threshold = 0.3
	new_text = new_text.to_lower()
	
	if not new_text.empty():
		for s in list:
			var similarity = s.to_lower().similarity(new_text)
			if s.begins_with(new_text):
				similarity += 0.4
			if similarity <= threshold: continue
			similarities.push_back({"text": s, "value": similarity})
		
	if not similarities:
		$Popup.clear()
		$Popup.hide()
		return
	
	similarities.sort_custom(self, "_sort_similarities")
	if similarities.size() > max_values:
		similarities.resize(max_values)
		
	var pos = rect_global_position
	pos.y += rect_size.y
	var size = rect_size
	size.y = 100
	$Popup.clear()
	for s in similarities:
		$Popup.add_item(s.text)
	$Popup.popup(Rect2(pos, size))
	
	grab_focus()
	
	check_text()

func _on_FuzzyLineEdit_text_entered(new_text):
	$Popup.hide()
	check_text()

func _on_Popup_id_pressed(ID):
	var v = $Popup.get_item_text(ID)
	text = v
	caret_position = text.length()
	emit_signal("text_entered", text)
	$Popup.hide()
	
	check_text()
