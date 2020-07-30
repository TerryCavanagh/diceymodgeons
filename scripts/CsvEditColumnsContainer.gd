extends PanelContainer

signal columns_changed()

onready var ColumnsTree = find_node("ColumnsTree")

var columns = []
var root = null

func _ready():
	pass

func set_columns(columns):
	ColumnsTree.clear()
	root = ColumnsTree.create_item()
	self.columns = columns
	for column in columns:
		var row = ColumnsTree.create_item(root)
		row.set_editable(0, true)
		row.set_selectable(0, true)
		row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		row.set_text(0, column)


func _on_RemoveColumnButton_pressed():
	var row = ColumnsTree.get_selected()
	if row:
		root.remove_child(row)
		row.free()
		root.select(0)


func _on_AddColumnButton_pressed():
	var row = ColumnsTree.create_item(root)
	row.set_editable(0, true)
	row.set_selectable(0, true)
	row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	row.select(0)
	ColumnsTree.ensure_cursor_is_visible()
