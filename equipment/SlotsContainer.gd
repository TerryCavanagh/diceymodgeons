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
var slots:Array = []

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
	visible = not slots.empty()
	
	for slot in SlotOptions:
		slot.visible = false
		Utils.connect_signal(slot, "Slots", "item_selected", self, "_on_Slot_item_selected")
	
	SlotsNumberSpin.value = slots.size()
	Utils.connect_signal(SlotsNumberSpin, "Nothing", "value_changed", self, "_on_SlotsNumberSpin_value_changed")
	
	for i in slots.size():
		var slot = slots[i]
		if slot.empty():
			continue
		SlotOptions[i].visible = true
		Utils.option_select(SlotOptions[i], slot)
	
	var total = data.get("NEED TOTAL?", null)
	if total:
		ExtraSpin.value = total
	else:
		ExtraSpin.value = -1
		
	_check()
	
func _check():
	var slots = []
	for i in SlotOptions.size():
		if not SlotOptions[i].visible:
			continue
		var slot = Utils.option_get_selected_key(SlotOptions[i])
		if not slot.empty():
			slots.push_back(slot)
			
	ExtraContainer.visible = false
	ExtraSpin.min_value = 0
	var result = true
	var error = ""
	if slots.size() == 1 and slots[0] == "COUNTDOWN":
		ExtraContainer.visible = true
		ExtraSpin.min_value = 1
		ExtraLabel.text = "Countdown:"
	elif slots.size() == 2 and slots[0] == "NORMAL" and slots[1] == "NORMAL":
		ExtraContainer.visible = true
		ExtraSpin.min_value = -1
		ExtraLabel.text = "Optional minimum sum value:"
	
	if slots.size() > 1 and slots.has("COUNTDOWN"):
		result = false
		error = "COUNTDOWN cards can only have 1 slot"
		
	if result:
		ErrorLabel.modulate = Color.green
		ErrorLabel.text = "All correct."
	else:
		ErrorLabel.modulate = Color.red
		ErrorLabel.text = error
		
	return result
	
func _on_Slot_item_selected(idx, node, key):
	if not data_id: return
	Utils.update_option_tooltip(node, idx)
	# get the new values from the slots
	# check them
	# emit signal if slots are okay
	_check()
	
func _on_SlotsNumberSpin_value_changed(value, node, key):
	if not data_id: return
	for i in SlotOptions.size():
		if i < value:
			if not SlotOptions[i].visible:
				SlotOptions[i].visible = true
		else:
			SlotOptions[i].visible = false
			
	_check()
	
func _on_ExtraSpin_value_changed(value, node, key):
	if not data_id: return