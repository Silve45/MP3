extends Control

@onready var songNameLabel = $songName
#@onready var hboxContainer = $Panel/ScrollContainer/VBoxContainer/HBoxContainer
@onready var vboxContainer = $Panel/ScrollContainer/VBoxContainer


var array = ["name1", "name2", "name3", "name4", "name5", "name6"]
var currentHboxContainer #= $Panel/ScrollContainer/VBoxContainer/HBoxContainer
signal sendSong

func _ready():
	visible = false
	Globals.connect("changeArray", _set_array)
	_make_buttons()

func _set_array():
	array = Globals.globalMusicArray
	_make_buttons()
	print("set array called")

func _make_new_hbox():
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 86)
	vboxContainer.add_child(hbox)
	currentHboxContainer = hbox

func _make_buttons():
	#clear old for new
	for n in vboxContainer.get_children():
		vboxContainer.remove_child(n)
	_make_new_hbox()
	for n in array.size():
		var button = recordButton.new()
		
		button.buttonInfo = array[n]
		button.buttonName = _song_title(array[n])
		button.mouse_entered.connect(_display_song_name.bind(button))
		button.pressed.connect(_play_song.bind(button))
		if currentHboxContainer.get_child_count() < 5:
			currentHboxContainer.add_child(button)
		else:
			_make_new_hbox()
			currentHboxContainer.add_child(button)

func _song_title(string):
	var bacon = string
	var num = bacon.rfind('/')
	var title = bacon.right(-(num + 1))
	var num2 = title.rfind('.')
	var newTitle = title.left(num2)
	#print(newTitle)
	
	return newTitle

func _display_song_name(button):
	songNameLabel.set_text(button.buttonName)

func _play_song(button):
	print("playing song ", button.buttonName)
	Globals.nextSong = button.buttonInfo
	emit_signal("sendSong")

func _on_close_pressed():
	visible = false
