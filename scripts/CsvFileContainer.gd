extends PanelContainer

signal text_changed(value)
signal delete_pressed(file_name, node)

onready var FilePathContainer = find_node("FilePathContainer")
onready var CsvTree = find_node("CsvTree")
onready var Separators = find_node("Separators")
onready var EditColumnsDialog = find_node("EditColumnsDialog")
onready var CsvEditColumnsContainer = find_node("CsvEditColumnsContainer")

var path = ""
var file_name = ""
var loaded_file:Dictionary = {}

func _ready():
	# Hacky way of getting the hscroll from the csvtree control
	for child in CsvTree.get_children():
		if child is HScrollBar:
			child.connect("value_changed", self, "_on_CsvTree_HScroll_value_changed")

func set_data(path, filename):
	if not filename.empty() and filename.is_valid_filename():
		file_name = filename
		self.path = path
		var file = ModFiles.get_file('data/text/scripts/%s' % filename)

		if file:
			loaded_file = file
			setup_csv(file.file)
			FilePathContainer.text = file.path
		else:
			clear_csv()
			FilePathContainer.clear()

func setup_csv(file:File):
	clear_csv()

	CsvTree.set_column_titles_visible(true)

	var root = CsvTree.create_item()
	if file.get_as_text().empty():
		print("Show wizard")
	else:
		var is_titles = true
		var columns = -1
		while not file.eof_reached():
			if is_titles:
				var titles = file.get_csv_line(",")
				columns = titles.size()
				CsvTree.columns = columns
				for i in titles.size():
					CsvTree.set_column_title(i, titles[i])
					CsvTree.set_column_expand(i, true)
					CsvTree.set_column_min_width(i, 150)

				CsvEditColumnsContainer.set_columns(titles)

				is_titles = false

				continue

			var values = file.get_csv_line(",")
			var row = CsvTree.create_item(root)
			for i in values.size():
				row.set_cell_mode(i, TreeItem.CELL_MODE_STRING)
				row.set_text(i, values[i])
				row.set_editable(i, false)

		for j in 100:
			var row = CsvTree.create_item(root)
			for i in columns:
				row.set_cell_mode(i, TreeItem.CELL_MODE_STRING)
				row.set_text(i, "")
				row.set_editable(i, false)

		file.close()

		call_deferred("_update_separators")

func clear_csv():
	CsvTree.clear()

func needs_save():
	return ModFiles.file_needs_save(path)

func _update_separators():
	var width = 0.0
	for i in CsvTree.columns:
		var vseparator = null
		if Separators.get_child_count() - 1 >= i and Separators.get_child(i) is VSeparator:
			vseparator = Separators.get_child(i)
		else:
			vseparator = VSeparator.new()
			Separators.add_child(vseparator)
			vseparator.connect("gui_input", self, "_on_vseparator_gui_input", [vseparator, i])

		vseparator["custom_constants/separation"] = 10
		vseparator.size_flags_vertical = Control.SIZE_EXPAND_FILL

		vseparator.rect_size.y = 5000
		vseparator.mouse_default_cursor_shape = Control.CURSOR_HSIZE
		width += CsvTree.get_column_width(i)
		vseparator.rect_position.x = -CsvTree.get_scroll().x + width


func _on_CsvTree_item_activated():
	var selected = CsvTree.get_selected()
	var col = -1

	for i in CsvTree.columns:
		if selected.is_selected(i):
			col = i
			break

	if col > -1:
		print('Selected text is %s' % selected.get_text(col))

func _on_CsvTree_column_title_pressed(column):
	print('Column %s pressed' % column)

func _on_CsvTree_resized():
	call_deferred("_update_separators")

func _on_CsvTree_HScroll_value_changed(new_value):
	call_deferred("_update_separators")

func _on_EditColumnsButton_pressed():
	EditColumnsDialog.popup_centered_minsize(Vector2(800, 400))

func _on_vseparator_gui_input(event:InputEvent, separator:VSeparator, column:int):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.button_index == BUTTON_LEFT:
			separator.set_meta("pressed", event.pressed)

	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		if separator.has_meta("pressed") and separator.get_meta("pressed"):
			var width = CsvTree.get_column_width(column)
			width += event.relative.x
			if width < 20:
				width = 20
			else:
				separator.rect_position.x += event.relative.x

			CsvTree.set_column_min_width(column, width)
			call_deferred("_update_separators")
