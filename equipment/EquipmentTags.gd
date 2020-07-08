extends HBoxContainer

onready var TagsContainer = find_node("TagsContainer")
onready var TagsButton = find_node("TagsButton")

var data_id:String = ""
var data:Dictionary = {}

func _ready():
	
	var popup:PopupMenu = TagsButton.get_popup()
	var idx = 0
	for tag in Gamedata.items.get("default_tags", {}):
		popup.add_check_item(Gamedata.items.default_tags.get(tag), idx)
		popup.set_item_as_checkable(idx, true)
		popup.set_item_tooltip(idx, tag)
		idx += 1

func set_data(data):
	data_id = Database.get_data_id(data, "Name")
	self.data = data
	
	_setup(TagsButton, "Tags", [])
	
func _setup(node, key, def):
	if node == TagsButton:
		var tags = data.get("Tags", def)
		var popup:PopupMenu = TagsButton.get_popup()
		Utils.connect_signal(popup, key, "id_pressed", self, "_on_TagsButton_popup_id_pressed")
		
		for idx in popup.get_item_count():
			popup.set_item_checked(idx, Gamedata.items.default_tags.keys()[idx] in tags)
		
		for child in TagsContainer.get_children():
			TagsContainer.remove_child(child)
			child.queue_free()
		for tag in tags:
			add_tag(tag)

func add_tag(new_tag):
	var label = Label.new()
	TagsContainer.add_child(label)
	label.text = new_tag
	label.set_meta("tag", new_tag)
	label.grab_focus()
	# TODO add it to the data
	
func remove_tag(tag):
	for child in TagsContainer.get_children():
		if child.has_meta("tag") and child.get_meta("tag") == tag:
			TagsContainer.remove_child(child)
			child.queue_free()
			# TODO remove it from the data
			break

func _on_TagsButton_popup_id_pressed(idx, node, key):
	node.toggle_item_checked(idx)
	var value = Gamedata.items.default_tags.keys()[idx]
	if node.is_item_checked(idx):
		add_tag(value)
	else:
		remove_tag(value)
