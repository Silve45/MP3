class_name playlistButton
extends Button
var array = []
var num
#needs to be able to save array ( do this next time )

func _ready():
	custom_minimum_size.x = 300
	custom_minimum_size.y = 300
	add_theme_font_size_override("font_size", 200)
	theme = load("res://resources/themes/blueButtonTheme.tres")
	SaveData.connect("changeNum", _changeNum)

func _changeNum():
	num = get_index()
	print("new index is ", num)
	text = str(num)
