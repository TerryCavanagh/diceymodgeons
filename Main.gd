extends PanelContainer

export (int) var disable_tabs = 0

onready var TabContainer = find_node("TabContainer")
onready var ModSettings = find_node("Mod Settings")
onready var Enemies = find_node("Enemies")
onready var Equipment = find_node("Equipment")
onready var Items = find_node("Skills")
onready var StatusEffects = find_node("Status Effects")
onready var Characters = find_node("Characters")

onready var PopupBackground = find_node("PopupBackground")

onready var ModifiedDataContainer = find_node("ModifiedDataContainer")

func _ready():
	_set_window_title()
	# Disable auto accept quit to be able to ask for saving before quitting
	get_tree().set_auto_accept_quit(false)
	# Disable tabs
	for i in disable_tabs:
		TabContainer.set_tab_disabled(i+1, true)
	Database.connect("data_loaded", self, "_on_Database_data_loaded")

func _process(delta):
	PopupBackground.visible = PopupBackgroundHelper.windows_shown_count > 0

	# TODO make this better
	ModifiedDataContainer.visible = Database.data_needs_save()

func _set_window_title(mod = null):
	var current_mod = "No mod loaded"
	if mod:
		current_mod = "Loaded mod: %s" % mod

	var title = ProjectSettings.get_setting("application/config/name")
	var api = ProjectSettings.get_setting("application/config/mod_api_version")
	# setup some window information
	OS.set_window_title("%s - %s - Mod API %s" % [title, current_mod, api])

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

func _on_Database_data_loaded(mod, id):
	_set_window_title(mod)
	for i in disable_tabs:
		TabContainer.set_tab_disabled(i+1, false)

	Enemies.TreeList.start_load()
	Equipment.ItemList.start_load()
	Items.ItemList.start_load()
	Characters.CharacterList.start_load()
	StatusEffects.StatusList.start_load()

	TabContainer.current_tab += 1
