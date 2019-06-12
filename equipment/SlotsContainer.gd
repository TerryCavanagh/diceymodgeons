extends PanelContainer

signal total_changed(new_total)
signal slots_changed(slots)

onready var SlotsNumberSpin = find_node("SlotsNumberSpin")

onready var SlotOptions:Array = []

onready var ExtraContainer = find_node("ExtraContainer")
onready var ExtraLabel = find_node("ExtraLabel")
onready var ExtraSpin = find_node("ExtraSpin")

onready var ErrorLabel = find_node("ErrorLabel")

var data_id:String = ""
var data:Dictionary = {}
var current_slots:Array = []
var slots:Array = []

var is_valid = false

func _ready():
	var dict = Gamedata.items.get("slots", {})
	for i in 4:
		var slot = find_node("Slot%sOption" % (i+1))
		Utils.fill_options(slot, dict)
		slot.visible = false
		SlotOptions.push_back(slot)
	
func set_data(data):
	self.data_id = data.get("Name", "")
	self.data = data
	
	slots = data.get("Slots", [])
	current_slots = slots.duplicate()
	
	visible = not slots.empty()
	
	for slot in SlotOptions:
		slot.visible = false
		Utils.connect_signal(slot, "Slots", "item_selected", self, "_on_Slot_item_selected")
	Utils.connect_signal(SlotsNumberSpin, "Nothing", "value_changed", self, "_on_SlotsNumberSpin_value_changed")
	
	Utils.connect_signal(ExtraSpin, "Nothing", "value_changed", self, "_on_ExtraSpin_value_changed")
	
	SlotsNumberSpin.value = slots.size()
	
	for i in slots.size():
		var slot = slots[i]
		if slot.empty():
			continue
		SlotOptions[i].visible = true
		Utils.option_select(SlotOptions[i], slot)
	
	# it will get visible if needed inside _check()
	ExtraSpin.visible = false
	
	var total = data.get("NEED TOTAL?", null)
	if total:
		ExtraSpin.value = total
	else:
		ExtraSpin.value = -1
		
	_check()
	
func _check()->bool:
	var slots = []
	for i in SlotOptions.size():
		if not SlotOptions[i].visible:
			continue
		var slot = Utils.option_get_selected_key(SlotOptions[i])
		if not slot.empty():
			slots.push_back(slot)
			
	ExtraContainer.visible = false
	ExtraContainer.hint_tooltip = ""
	ExtraSpin.visible = false
	ExtraSpin.min_value = 0
	
	var result = true
	var error = ""
	
	if slots.size() == 1 and slots[0] == "COUNTDOWN":
		ExtraContainer.visible = true
		ExtraSpin.visible = true
		ExtraSpin.min_value = 1
		# force emitting the value_changed signal
		ExtraSpin.value = ExtraSpin.value
		ExtraLabel.text = "Countdown:"
		
	elif slots.size() == 2 and slots[0] == "NORMAL" and slots[1] == "NORMAL":
		ExtraContainer.visible = true
		ExtraSpin.visible = true
		ExtraSpin.min_value = -1
		# force emitting the value_changed signal
		ExtraSpin.value = ExtraSpin.value
		ExtraLabel.text = "Optional minimum sum value:"
		ExtraContainer.hint_tooltip = "Set it to -1 to disable a minimum sum."
	
	if slots.has("COUNTDOWN") and slots.size() > 1:
		result = false
		error = "COUNTDOWN equipment can only have 1 slot."
	elif slots.has("DOUBLES") and (not slots.size() == 2 or not (slots[0] == "DOUBLES" and slots[1] == "DOUBLES")):
		result = false
		error ="Equipment can only have 2 DOUBLES slots."
		
	if result:
		ErrorLabel.modulate = Color.green
		ErrorLabel.text = "All correct."
	else:
		ErrorLabel.modulate = Color.red
		ErrorLabel.text = error
		
	is_valid = result
	current_slots = slots
	
	return result
	
func _on_Slot_item_selected(idx, node, key):
	if not data_id or not visible: return
	Utils.update_option_tooltip(node, idx)
	if _check():
		emit_signal("slots_changed", current_slots)
	
func _on_SlotsNumberSpin_value_changed(value, node, key):
	if not data_id or not visible: return
	for i in SlotOptions.size():
		if i < value:
			if not SlotOptions[i].visible:
				SlotOptions[i].visible = true
		else:
			SlotOptions[i].visible = false
			
	if _check():
		emit_signal("slots_changed", current_slots)
	
func _on_ExtraSpin_value_changed(value, node, key):
	if not data_id or not ExtraContainer.visible or not node.visible: return
	if value == -1: value = null
	emit_signal("total_changed", value)
