extends MenuButton

func _ready():
	var ev = InputEventKey.new()
	ev.scancode = KEY_F
	ev.alt = true
	shortcut = ShortCut.new()
	shortcut.shortcut = ev
	var popup = get_popup()
	popup.connect("index_pressed", self, "_on_PopupMenu_index_pressed")
	popup.rect_min_size.x = 200
	popup.clear()
	#_create_item(popup, "New mod...", KEY_N, "new", true)
	#_create_item(popup, "Open mod...", KEY_O, "open", true)
	_create_item(popup, "Save", KEY_S, "save", true)
	#popup.add_separator()
	#_create_item(popup, "Preferences", KEY_P, "preferences", true)
	popup.add_separator()
	_create_item(popup, "Quit", KEY_Q, "quit", true)

func _create_item(popup:PopupMenu, label:String, scancode:int, meta, ctrl:bool = false, alt:bool = false, shift:bool = false):
	var ev = InputEventKey.new()
	ev.scancode = scancode
	ev.meta = false
	if OS.get_name() == "OSX":
		ev.command = ctrl
	else:
		ev.control = ctrl
	ev.alt = alt
	ev.shift = shift
	var shortcut = ShortCut.new()
	shortcut.resource_name = label
	shortcut.shortcut = ev
	popup.add_shortcut(shortcut)
	popup.set_item_metadata(popup.get_item_count() - 1, meta)

func _on_PopupMenu_index_pressed(idx):
	var popup = get_popup()
	var meta = popup.get_item_metadata(idx)
	# TODO check that the data has been saved before new, open or quit
	match meta:
		"new":
			pass
		"open":
			pass
		"save":
			if Database.data_needs_save():
				Database.save_data()
		"preferences":
			pass
		"quit":
			get_tree().notification(NOTIFICATION_WM_QUIT_REQUEST)
