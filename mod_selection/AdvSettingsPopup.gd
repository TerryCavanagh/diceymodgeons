extends WindowDialog

onready var CharNameEdit = find_node("CharNameEdit")
onready var EnemyEdit = find_node("EnemyEdit")
onready var EqEdit = find_node("EqEdit")
onready var BossNameEdit = find_node("BossNameEdit")
onready var RemixEdit = find_node("RemixEdit")
onready var GadgetEdit = find_node("GadgetEdit")
onready var EpisodeBox = find_node("EpisodeBox")
onready var SaveButton = find_node("SaveButton")
onready var CancelButton = find_node("CancelButton")
onready var allenemiesCheckBox = find_node("allenemiesCheckBox")

onready var okay_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)
onready var normal_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)
onready var wrong_style:StyleBoxFlat = get_stylebox("normal", "LineEdit").duplicate(true)

var translatormode = false
var episodebutton = false
var remixbutton = false
var bossbutton = false
var characterbutton = false
var enemybutton = false
var eqbutton = false
var gadgetbutton = false
var emptybutton = false
var modecheatsbutton = false

var allenemies = ""
var character = ""
var episode = 1
var enemy = ""
var eq = ""
var boss = ""
var remix = ""
var gadget = ""

var valid_nodes := {}
var all_valid:bool = false

func _ready():
	okay_style.border_color = Color.green.darkened(0.5)
	wrong_style.border_color = Color.red.darkened(0.5)
	

func _process(delta):
	for v in valid_nodes.values():
		if not v:
			all_valid = false
			break



func show_popup():
	popup_centered_minsize(rect_min_size)


func _on_SaveButton_pressed():
	hide()


func _on_TranslatorCheckBox_toggled(button_pressed):
	translatormode = button_pressed
	pass # Replace with function body.


func _on_EpisodeButton_toggled(button_pressed):
	episodebutton = button_pressed
	pass # Replace with function body.


func _on_CharNameEdit_text_changed(new_text):
	character = new_text
	pass # Replace with function body.


func _on_EpisodeBox_value_changed(value):
	episode = int(value)
	pass # Replace with function body.


func _on_EnemyEdit_text_changed(new_text):
	enemy = new_text


func _on_EqEdit_text_changed(new_text):
	eq = new_text
	pass # Replace with function body.


func _on_BossNameEdit_text_changed(new_text):
	boss = new_text
	pass # Replace with function body.


func _on_RemixEdit_text_changed(new_text):
	remix = new_text

	pass # Replace with function body.


func _on_GadgetEdit_text_changed(new_text):
	gadget = new_text
	pass # Replace with function body.



func _on_EmptyCheckBox_toggled(button_pressed):
	emptybutton = button_pressed
	pass # Replace with function body.


func _on_ModCheatsCheckBox_toggled(button_pressed):
	modecheatsbutton = button_pressed
	pass # Replace with function body.


func _on_AllEnemiesEdit_text_changed(new_text):
	allenemies = new_text
	if (!allenemies == ""):
		BossNameEdit.editable = false
		BossNameEdit.text = ""
	else:
		BossNameEdit.editable = true
	pass # Replace with function body.
 # Replace with function body.
