extends Node

var windows_shown_count = 0

func _enter_tree():
	get_tree().connect("node_added", self, "_on_node_added")

func _on_node_added(node):
	if node is WindowDialog:
		node.connect("about_to_show", self, "_on_window_about_to_show")
		node.connect("popup_hide", self, "_on_window_popup_hide")

func _on_window_about_to_show():
	windows_shown_count += 1

func _on_window_popup_hide():
	windows_shown_count -= 1
	if windows_shown_count < 0:
		printerr("Something went wrong and got more popups hide than about to show")
		windows_shown_count = 0
