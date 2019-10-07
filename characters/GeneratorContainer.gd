extends PanelContainer

var data_id:String = ""
var data:Dictionary = {}

func set_data(data):
	data_id = Database.mixed_key(["Character", "Level"], data)
	self.data = data
