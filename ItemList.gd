extends VBoxContainer

signal item_selected(key)
signal add_button_pressed()


export (Database.Table) var table = Database.Table.FIGHTERS setget _set_table
export (String) var search_placeholder = "" setget _set_search_placeholder
export (String) var button_label = "" setget _set_button_label

onready var Search = find_node("Search")
onready var List = find_node("List")
onready var AddButton = find_node("AddButton")

var process_data_func:FuncRef = null setget _set_process_data_func
var modified_func:FuncRef = null setget _set_modified_func

func _ready():
	Search.placeholder_text = search_placeholder
	List.table = table
	AddButton.text = button_label
	
	List.process_data_func = process_data_func
	List.modified_func = modified_func
	
	
func start_load():
	List.load_data()

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

func _on_List_element_selected(key):
	emit_signal("item_selected", key)

func _on_AddButton_pressed():
	emit_signal("add_button_pressed")

func _set_process_data_func(value):
	process_data_func = value
	if not List: return
	List.process_data_func = process_data_func
	
func _set_modified_func(value):
	modified_func = value
	if not List: return
	List.modified_func = modified_func
