extends PanelContainer

func _ready():
	get_tree().set_auto_accept_quit(false)
	
func _notification(what):
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		print("Are you sure?")
		get_tree().quit()
