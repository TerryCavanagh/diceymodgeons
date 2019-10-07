extends VBoxContainer

signal value_changed(equipment, value)
signal item_selected(equipment)

export (String) var title = "" setget _set_title
export (bool) var can_add = true setget _set_can_add
export (bool) var can_remove = false setget _set_can_remove
export (bool) var can_sort = false setget _set_can_sort
export (bool) var show_prepared = false setget _set_show_prepared
export (bool) var order = true setget _set_order

export (bool) var show_upgraded_check = true setget _set_show_upgraded_check

onready var Title = find_node("Title")
onready var EquipTree = find_node("EquipTree")
onready var Search = find_node("Search")
onready var UpgradedCheck = find_node("UpgradedCheck")

var list:Array = []
var filter = null

func _ready():
	Title.text = title
	EquipTree.can_add = can_add
	EquipTree.can_remove = can_remove
	_set_show_prepared(show_prepared)
	UpgradedCheck.visible = show_upgraded_check
	EquipTree.can_sort = can_sort

func set_list(list, show_upgraded:bool = false, filter = null):
	self.list = list
	
	EquipTree.clear()
	
	if not filter and not Search.text.empty():
		filter = Search.text
	self.filter = filter
	
	if not show_upgraded_check or UpgradedCheck.pressed:
		show_upgraded = true
	
	var sublist:Array = []
	for item in list:
		var add = true
		if show_upgraded:
			if show_upgraded_check:
				if item.get("equipment", "").find("_upgraded") == -1:
					add = false
			else:
				if not (item.get("equipment", "").find("_") == -1 or item.get("equipment", "").find("_upgraded") > -1):
					add = false
		else:
			if item.get("equipment", "").find("_") > -1:
				add = false
		
		if not add: continue
		
		if filter:
			if item.get("equipment", "").findn(filter) > -1:
				sublist.push_back(item)
		else:
			sublist.push_back(item)
	
	if order:
		sublist.sort_custom(self, "_sort_equipment")
	
	var i = 0
	for item in sublist:
		var key = item.get("equipment", "")
		EquipTree.add_equipment(item)
		i += 1
	
func unselect_all():
	var selected = EquipTree.get_selected()
	if selected:
		selected.deselect(0)
	
func _sort_equipment(a, b):
	return a.get("equipment", "").nocasecmp_to(b.get("equipment", "")) < 0

func _on_Search_text_changed(new_text):
	set_list(list, UpgradedCheck.pressed, new_text)
	
func _on_EquipTree_equipment_selected(equipment):
	emit_signal("item_selected", equipment)
	
func _on_EquipTree_value_changed(equipment, value):
	emit_signal("value_changed", equipment, value)
	
func _on_UpgradedCheck_pressed():
	set_list(list, UpgradedCheck.pressed, filter)
	
func _on_EquipTree_list_updated(list):
	pass # Replace with function body.

func _set_title(v):
	title = v
	if not Title: return
	Title.text = v
	
func _set_can_add(v):
	can_add = v
	if not EquipTree: return
	EquipTree.can_add = v
	
func _set_can_remove(v):
	can_remove = v
	if not EquipTree: return
	EquipTree.can_remove = v
	
func _set_can_sort(v):
	can_sort = v
	if not EquipTree: return
	EquipTree.can_sort = v
	
func _set_order(v):
	order = v
	if not EquipTree: return
	set_list(list, UpgradedCheck.pressed, filter)

func _set_show_prepared(v):
	show_prepared = v
	if not EquipTree: return
	EquipTree.show_prepared = v
	set_list(list, UpgradedCheck.pressed, filter)

func _set_show_upgraded_check(v):
	show_upgraded_check = v
	if not UpgradedCheck: return
	UpgradedCheck.visible = v
