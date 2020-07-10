extends HBoxContainer

const TagContainerScene = preload("res://equipment/TagContainer.tscn")

onready var TagsContainer = find_node("TagsContainer")
onready var TagsButton = find_node("TagsButton")
onready var TmpControl = find_node("TmpControl")

var data_id:String = ""
var data:Dictionary = {}

func _ready():
	
	var popup:PopupMenu = TagsButton.get_popup()
	var idx = 0
	for tag in Gamedata.items.get("default_tags", {}):
		popup.add_check_item(Gamedata.items.default_tags.get(tag), idx)
		popup.set_item_as_checkable(idx, true)
		popup.set_item_tooltip(idx, tag)
		popup.set_item_metadata(idx, tag)
		idx += 1

func set_data(data):
	data_id = Database.get_data_id(data, "Name")
	self.data = data
	
	_setup(TagsButton, "Tags", [])
	
func _setup(node, key, def):
	if node == TagsButton:
		var popup:PopupMenu = TagsButton.get_popup()
		Utils.connect_signal(popup, key, "id_pressed", self, "_on_TagsButton_popup_id_pressed")
		load_tags()
			
func clear_tags():
	for child in TagsContainer.get_children():
		TagsContainer.remove_child(child)
		child.queue_free()
		
func load_tags():
	if not data: return
	print("loading tags")
	var tags = data.get("Tags", [])
	var popup:PopupMenu = TagsButton.get_popup()
	clear_tags()
	for idx in popup.get_item_count():
		var meta = popup.get_item_metadata(idx)
		popup.set_item_checked(idx, meta in tags)
	for tag in tags:
		add_tag(tag, false)

func add_tag(new_tag, to_db):
	var tag_container = TagContainerScene.instance()
	tag_container.connect("delete_requested", self, "remove_tag", [new_tag, true])
	tag_container.set_meta("tag", new_tag)
	tag_container.set_tag(new_tag, Gamedata.items.default_tags.get(new_tag, ""))
	# To get the minimum size of the tag container we need to add it to the tree first
	# but we can't add it directly to the container because we don't know if it will
	# fit or not. Because of this, we add it to a tmp control to get the correct size
	# Ideally we would make a custom container to calculate this but for this case
	# it should be enough.
	TmpControl.add_child(tag_container)
	
	var container:HBoxContainer = null
	if TagsContainer.get_child_count() > 0:
		container = TagsContainer.get_child(TagsContainer.get_child_count() - 1)
	var tag_container_size = tag_container.get_combined_minimum_size()
	if not container or (container.rect_size.x + tag_container_size.x) > TagsContainer.rect_size.x:
		container = HBoxContainer.new()
		container.size_flags_horizontal = 0
		TagsContainer.add_child(container)
	
	TmpControl.remove_child(tag_container)
	container.add_child(tag_container)
	
	if to_db:
		var tags = data.get("Tags")
		tags.push_back(new_tag)
		Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, "Tags", tags)
	
func remove_tag(tag, to_db):
	for container in TagsContainer.get_children():
		for child in container.get_children():
			if child.has_meta("tag") and child.get_meta("tag") == tag:
				container.remove_child(child)
				child.queue_free()
				
				var popup:PopupMenu = TagsButton.get_popup()
				for idx in popup.get_item_count():
					var meta = popup.get_item_metadata(idx)
					if meta == tag:
						popup.set_item_checked(idx, false)
				
				if to_db:
					var tags = data.get("Tags")
					tags.erase(tag)
					Database.commit(Database.Table.EQUIPMENT, Database.UPDATE, data_id, "Tags", tags)
				
				break
		if container.get_child_count() == 0:
			TagsContainer.remove_child(container)
			container.queue_free()

func _on_TagsButton_popup_id_pressed(idx, node, key):
	node.toggle_item_checked(idx)
	var value = Gamedata.items.default_tags.keys()[idx]
	if node.is_item_checked(idx):
		add_tag(value, true)
	else:
		remove_tag(value, true)
