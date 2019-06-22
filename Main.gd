extends PanelContainer

onready var TabContainer = find_node("TabContainer")
onready var ModSettings = find_node("Mod Settings")
onready var Enemies = find_node("Enemies")
onready var Equipment = find_node("Equipment")

onready var ModifiedDataContainer = find_node("ModifiedDataContainer")

func _ready():
	# setup some window information
	OS.set_window_title("%s - Mod API %s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/mod_api_version")])
	# Disable auto accept quit to be able to ask for saving before quitting
	get_tree().set_auto_accept_quit(false)
	# Disable tabs
	TabContainer.set_tab_disabled(1, true)
	TabContainer.set_tab_disabled(2, true)
	Database.connect("data_loaded", self, "_on_Database_data_loaded")
	
func _process(delta):
	var modal = get_viewport().get_modal_stack_top()
	var show_background = modal != null and modal is WindowDialog
	$PopupBackground.visible = show_background
	
	# TODO make this better
	ModifiedDataContainer.visible = Database.data_needs_save()
	
func _notification(what):
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		if Database.data_needs_save():
			ConfirmPopup.popup_save("Save changes before exiting?")
			var result = yield(ConfirmPopup, "action_chosen")
			match result:
				ConfirmPopup.OKAY:
					Database.save_data()
					get_tree().quit()
				ConfirmPopup.OTHER:
					get_tree().quit()
				ConfirmPopup.CANCEL:
					pass
		else:
			get_tree().quit()
		
func _on_Database_data_loaded():
	TabContainer.set_tab_disabled(1, false)
	TabContainer.set_tab_disabled(2, false)
	
	Enemies.TreeList.start_load()
	Equipment.ItemList.start_load()
