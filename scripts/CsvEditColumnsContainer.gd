extends PanelContainer

signal column_removed(column_name)
signal column_added(column_name)
signal column_edited(old_column_name, new_column_name)

onready var ColumnsTree = find_node("ColumnsTree")
onready var AddPopup = find_node("AddPopup")

var columns = []
var root = null

func _ready():
	AddPopup.add_func = funcref(self, "_add_column")
	AddPopup.check_valid_func = funcref(self, "_check_valid")
	root = ColumnsTree.create_item()

func set_columns(columns):
	ColumnsTree.clear()
	self.columns = columns
	for column in columns:
		var row = ColumnsTree.create_item(root)
		row.set_editable(0, true)
		row.set_selectable(0, true)
		row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		row.set_metadata(0, {"original": column})
		row.set_text(0, column)

func _add_column(text):
	columns.push_back(text)
	var row = ColumnsTree.create_item(root)
	row.set_editable(0, true)
	row.set_selectable(0, true)
	row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	row.set_metadata(0, {"original": text})
	row.set_text(0, text)
	row.select(0)
	ColumnsTree.ensure_cursor_is_visible()

func _check_valid(value):
	for column in columns:
		if value.to_lower() == column.to_lower():
			return false

	return true

func _on_RemoveColumnButton_pressed():
	var row = ColumnsTree.get_selected()
	if row:
		root.remove_child(row)
		var meta = row.get_metadata(0)
		emit_signal("column_removed", meta.get("original", ""))
		row.free()
		root.select(0)

func _on_AddColumnButton_pressed():
	AddPopup.popup_centered(Vector2(400, 120))
	return

func _on_ColumnsTree_item_edited():
	var selected = ColumnsTree.get_selected()
	var meta = selected.get_metadata(0)
	var old = meta.get("original", "")
	var new = selected.get_text(0)
	emit_signal("column_edited", old, new)
	selected.set_metadata(0, {"original": new})
