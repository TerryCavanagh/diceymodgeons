extends PanelContainer

signal text_changed(value)
signal delete_pressed(file_name, node)
signal close_pressed(file_name, node)

onready var FilePathContainer = find_node("FilePathContainer")
onready var CsvTree = find_node("CsvTree")
onready var Separators = find_node("Separators")
onready var EditColumnsDialog = find_node("EditColumnsDialog")
onready var CsvEditColumnsContainer = find_node("CsvEditColumnsContainer")

var path = ""
var file_name = ""
var loaded_file:ModFiles.CsvFile = null
var columns = 0

func _ready():
	# Hacky way of getting the hscroll from the csvtree control
	for child in CsvTree.get_children():
		if child is HScrollBar:
			child.connect("value_changed", self, "_on_CsvTree_HScroll_value_changed")

	CsvEditColumnsContainer.connect("column_added", self, "_on_column_added")
	CsvEditColumnsContainer.connect("column_edited", self, "_on_column_edited")
	CsvEditColumnsContainer.connect("column_removed", self, "_on_column_removed")

func set_data(path, filename):
	if not filename.empty() and filename.is_valid_filename():
		file_name = filename
		self.path = path
		var file = ModFiles.get_file_csv('data/text/scripts/%s' % filename)

		if file:
			loaded_file = file
			setup_csv(file)
			FilePathContainer.text = file.path
		else:
			clear_csv()
			FilePathContainer.clear()

func setup_csv(file):
	clear_csv()

	CsvTree.set_column_titles_visible(true)

	var root = CsvTree.create_item()

	if file.headers.empty():
		print("file is empty")
	else:
		var titles = file.headers
		columns = titles.size()
		CsvTree.columns = columns
		for i in titles.size():
			CsvTree.set_column_title(i, titles[i])
			CsvTree.set_column_expand(i, true)
			CsvTree.set_column_min_width(i, 150)

		CsvEditColumnsContainer.set_columns(titles)

		var total_lines = file.csv.size()

		for j in total_lines:
			var values = file.csv[j]
			var row = CsvTree.create_item(root)
			row.set_metadata(0, {"index": j})
			for i in columns:
				var value = values[i]
				if not value:
					value = ""
				row.set_cell_mode(i, TreeItem.CELL_MODE_STRING)
				row.set_text(i, value)
				row.set_editable(i, true)

		for j in 100:
			var row = CsvTree.create_item(root)
			row.set_metadata(0, {"index": total_lines + j})
			for i in columns:
				row.set_cell_mode(i, TreeItem.CELL_MODE_STRING)
				row.set_text(i, "")
				row.set_editable(i, true)

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

	if Separators.get_child_count() > CsvTree.columns:
		for i in range(CsvTree.columns, Separators.get_child_count()):
			var child = Separators.get_child(i)
			Separators.remove_child(child)
			child.queue_free()

func _ensure_size(rows:int):
	var current = loaded_file.csv.size()
	if current < rows+1:
		loaded_file.csv.resize(rows+1)
		for i in range(current, rows+1):
			loaded_file.csv[i] = []
			loaded_file.csv[i].resize(columns)
			for col in columns:
				loaded_file.csv[i][col] = ""

func _on_column_added(column_name):
	CsvTree.columns += 1

	CsvTree.set_column_title(CsvTree.columns, column_name)
	CsvTree.set_column_expand(CsvTree.columns, true)
	CsvTree.set_column_min_width(CsvTree.columns, 150)

	emit_signal("text_changed", "")
	call_deferred("_update_separators")


func _on_column_removed(column_name):
	pass

func _on_column_edited(old_column_name, new_column_name):
	for i in CsvTree.columns:
		if CsvTree.get_column_title(i) == old_column_name:
			CsvTree.set_column_title(i, new_column_name)

	var idx = loaded_file.headers.find(old_column_name)
	if idx > -1:
		loaded_file.headers[idx] = new_column_name

	emit_signal("text_changed", "")
	call_deferred("_update_separators")

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


func _on_CsvTree_item_edited():
	var current = CsvTree.get_selected()
	if not current.get_metadata(0):
		print("This edited item has no metadata D:")
		return

	var row = current.get_metadata(0).get("index", 0)
	var col = CsvTree.get_selected_column()
	var text = current.get_text(col)
	_ensure_size(row)
	var old = loaded_file.csv[row][col]
	print('Item (row=%s col=%s) old %s text %s' % [row, col, old, text])
	loaded_file.csv[row][col] = text
	print(loaded_file.csv[row])
	emit_signal("text_changed", text)

func _on_FilePathContainer_close_pressed():
	emit_signal("close_pressed", path, self)

func _on_FilePathContainer_delete_pressed():
	emit_signal("delete_pressed", path, self)
