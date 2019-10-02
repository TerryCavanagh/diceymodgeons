extends Tree

signal equipment_selected(equipment)
signal value_changed(equipment, value)

enum {
	NAME = 0,
	PREPARED = 1
}

var show_prepared = true setget _set_show_prepared
var can_sort = false

var can_add = true
var can_remove = true

func _ready():
	set_column_expand(NAME, true)
	set_column_expand(PREPARED, false)
	_set_show_prepared(show_prepared)
	
	clear()
	
	
func clear():
	.clear()
	create_item()
	
func add_equipment(equipment):
	if not equipment: return
	var it = create_item(get_root())
	it.set_text(NAME, equipment.get("equipment", "!!!"))
	it.set_metadata(NAME, equipment)
	
	if show_prepared:
		it.set_cell_mode(PREPARED, TreeItem.CELL_MODE_CHECK)
		it.set_checked(PREPARED, equipment.get("prepared", false))
	

func can_drop_data(position, data):
	return data is Dictionary and data.has("equipment") and not data.get("source", null) == self

func drop_data(position, data):
	if can_add:
		add_equipment(data.equipment)
		emit_signal("value_changed", data.equipment, true)
		
	if data.source.can_remove:
		var root = data.source.get_root()
		root.remove_child(data.item)
		data.source.emit_signal("value_changed", data.equipment, false)
	
func get_drag_data(position):
	var item = get_item_at_position(position)
	if not item: return null
	print("drag data ", position, " ", item.get_metadata(NAME))
	return {"equipment": item.get_metadata(NAME), "source": self, "item": item}

func _on_EquipTree_cell_selected():
	var it = get_selected()
	if get_selected_column() == PREPARED:
		var c = it.is_checked(PREPARED)
		it.set_checked(PREPARED, not c)
		# TODO check that only up to 4 equipment can be prepared, error if there's more than that
		var meta = it.get_metadata(NAME)
		meta["prepared"] = not c
		it.set_metadata(NAME, meta)
		it.select(NAME)
		
	emit_signal("equipment_selected", it.get_metadata(NAME))
	
func _set_show_prepared(v):
	show_prepared = v
	if show_prepared:
		set_column_min_width(PREPARED, 24)
	else:
		# 0 doesn't work for some reason
		set_column_min_width(PREPARED, 1)
