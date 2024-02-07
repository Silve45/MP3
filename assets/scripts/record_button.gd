class_name recordButton
extends TextureButton

var buttonName = "coolname"
var buttonInfo 
signal search
#@onready var label = $Label

func _ready():
	texture_normal = load("res://assets/sprites/record.png")
	var label = Label.new()
	#label.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	label.position.y = 71
	label.theme = load("res://resources/themes/toastTheme.tres") 
	label.set_text(buttonName)
	label.visible_characters = 11
	add_child(label)
	Globals.connect("forceSearch", _emit_search)

func _emit_search():
	emit_signal("search")
	#print("record button's search called")#worked!

func _set_name(text, info):
	buttonName = text
	buttonInfo = info

#make it so that song is put up next then played
func _on_pressed():
	pass # Replace with function body.

func _on_mouse_entered():
	pass # Replace with function body.
