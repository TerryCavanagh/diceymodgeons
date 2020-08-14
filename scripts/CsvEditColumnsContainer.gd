extends PanelContainer

signal column_removed(column_name)
signal column_added(column_name)
signal column_edited(old_column_name, new_column_name)

onready var ColumnsTree = find_node("ColumnsTree")
onready var AddPopup = find_node("AddPopup")
onready var ConfirmPopup = find_node("ConfirmPopup")

var columns = []
var root = null

func _ready():
	root = ColumnsTree.create_item()
	AddPopup.add_func = funcref(self, "_add_column")
	AddPopup.check_valid_func = funcref(self, "_check_valid")

func set_columns(columns):
	ColumnsTree.clear()
	root = ColumnsTree.create_item()
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

	emit_signal("column_added", text)

func _check_valid(value):
	for column in columns:
		if value.to_lower() == column.to_lower():
			return false

	return true

func _on_RemoveColumnButton_pressed():
	var row = ColumnsTree.get_selected()
	if row:
		var meta = row.get_metadata(0)
		var col = meta.get("original", "")
		ConfirmPopup.popup_confirm("Are you sure that you want to delete the column \"%s\"?\n(This action cannot be undone)" % col)
		var result = yield(ConfirmPopup, "action_chosen")
		match result:
			ConfirmPopup.OKAY:
				emit_signal("column_removed", col)
				root.remove_child(row)
				root.select(0)

func _on_AddColumnButton_pressed():
	AddPopup.popup_centered(Vector2(400, 120))

func _on_ColumnsTree_item_edited():
	var selected = ColumnsTree.get_selected()
	var meta = selected.get_metadata(0)
	var old = meta.get("original", "")
	var new = selected.get_text(0)
	selected.set_metadata(0, {"original": new})
	emit_signal("column_edited", old, new)

