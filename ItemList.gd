extends VBoxContainer

signal item_selected(key)
signal add_button_pressed()
signal overwrite_mode_changed(new_value)


export (Database.Table) var table = Database.Table.FIGHTERS setget _set_table
export (String) var search_placeholder = "" setget _set_search_placeholder
export (String) var button_label = "" setget _set_button_label
export (bool) var sort_items = true setget _set_sort_items
export (String) var show_field = "" setget _set_show_field
export (bool) var show_overwrite_mode = true setget _set_show_overwrite_mode

onready var Search = find_node("Search")
onready var List = find_node("List")
onready var AddButton = find_node("AddButton")
onready var OverwriteCheck = find_node("OverwriteCheck")

var process_data_func:FuncRef = null setget _set_process_data_func
var modified_func:FuncRef = null setget _set_modified_func
var change_text_func:FuncRef = null setget _set_change_text_func

func _ready():
	Search.placeholder_text = search_placeholder
	List.table = table
	AddButton.text = button_label
	List.sort_items = sort_items
	List.show_field = show_field
	
	List.process_data_func = process_data_func
	List.modified_func = modified_func
	List.change_text_func = change_text_func
	
	OverwriteCheck.visible = show_overwrite_mode
	
	
func start_load():
	if Database.is_overwrite_mode(table):
		OverwriteCheck.pressed = true
		List.overwrite_mode = true
	else:
		OverwriteCheck.pressed = false
		List.overwrite_mode = false
	List.load_data()
	
func force_reload(select_key = null):
	List.force_reload(select_key)
	
func force_overwrite_mode(value):
	_on_OverwriteCheck_toggled(value)

func _set_search_placeholder(v):
	search_placeholder = v
	if not Search: return
	Search.placeholder_text = v
	
func _set_table(v):
	table = v
	if not List: return
	List.table = v
	
func _set_button_label(v):
	button_label = v
	if not AddButton: return
	AddButton.text = v
	
func _set_sort_items(v):
	sort_items = v
	if not List: return
	List.sort_items = v
	
func _set_show_field(v):
	show_field = v
	if not List: return
	List.show_field = v

func _on_List_element_selected(key):
	emit_signal("item_selected", key)

func _on_AddButton_pressed():
	emit_signal("add_button_pressed")

func _on_OverwriteCheck_toggled(button_pressed):
	List.overwrite_mode = button_pressed
	emit_signal("overwrite_mode_changed", button_pressed)
	Database.set_overwrite_mode(table, button_pressed)
	List.force_reload()
	
func _set_process_data_func(value):
	process_data_func = value
	if not List: return
	List.process_data_func = process_data_func
	
func _set_modified_func(value):
	modified_func = value
	if not List: return
	List.modified_func = modified_func
	
func _set_change_text_func(value):
	change_text_func = value
	if not List: return
	List.change_text_func = change_text_func
	
func _set_show_overwrite_mode(value):
	show_overwrite_mode = value
	if not OverwriteCheck: return
	OverwriteCheck.visible = value
