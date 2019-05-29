extends VBoxContainer

signal value_changed(equipment, value)
signal item_selected(equipment)

export (String) var title = "" setget _set_title
export (bool) var can_add = true setget _set_can_add
export (bool) var can_remove = false setget _set_can_remove

onready var Title = find_node("Title")
onready var List = find_node("List")
onready var Search = find_node("Search")

var list:Array = []

func _ready():
	Title.text = title
	List.can_add = can_add
	List.can_remove = can_remove

func set_list(list, filter = null):
	self.list = list
	
	List.clear()
	
	if not filter and not Search.text.empty():
		filter = Search.text
	
	var sublist:Array
	if filter:
		sublist = []
		for l in list:
			if l.findn(filter) > -1:
				sublist.push_back(l)
	else:
		sublist = list
	
	var i = 0
	for key in sublist:
		List.add_item(key)
		List.set_item_metadata(i, key)
		i += 1
		
	List.sort_items_by_text()
	
func unselect_all():
	List.unselect_all()

func _on_Search_text_changed(new_text):
	set_list(list, new_text)

func _on_List_item_selected(index):
	var key = List.get_item_metadata(index)
	emit_signal("item_selected", key)
	
func _on_List_value_changed(equipment, value):
	emit_signal("value_changed", equipment, value)

func _set_title(v):
	title = v
	if not Title: return
	Title.text = v
	
func _set_can_add(v):
	can_add = v
	if not List: return
	List.can_add = v
	
func _set_can_remove(v):
	can_remove = v
	if not List: return
	List.can_remove = v
