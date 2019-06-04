extends Node

func connect_signal(node:Node, key:String, _signal:String, _target:Node, _func:String)->void:
	var param = [_signal, _target, _func]
	if node.callv("is_connected", param):
		node.callv("disconnect", param)
	param.push_back([node, key])
	node.callv("connect", param)
	
func fill_options(node:OptionButton, data, capitalize:bool = false)->void:
	node.clear()
	if data is Array:
		for value in data:
			var v = value.capitalize() if capitalize else value
			node.add_item(v)
			var idx = node.get_item_count() - 1
			node.set_item_metadata(idx, {"tooltip": "", "key": value})
		node.set_meta("list", data)
	elif data is Dictionary:
		var popup = node.get_popup()
		for key in data.keys():
			var v = key.capitalize() if capitalize else key
			node.add_item(v)
			var idx = node.get_item_count() - 1
			
			var tooltip = data.get(key, "")
			
			node.set_item_metadata(idx, {"tooltip": tooltip, "key": key})
			
			if not tooltip.empty():
				popup.set_item_tooltip(idx, tooltip)
		node.set_meta("dict", data)
		
	Utils.update_option_tooltip(node, 0)

func update_option_tooltip(node:Node, idx:int)->void:
	var meta = node.get_item_metadata(idx)
	if not meta: return
	var tooltip = meta.get("tooltip", "")
	if tooltip.empty():
		node.hint_tooltip = ""
	else:
		node.hint_tooltip = tooltip