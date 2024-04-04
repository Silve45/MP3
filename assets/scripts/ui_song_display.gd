extends Control

@onready var songNameLabel = $songName
@onready var gridContainer = $Panel/ScrollContainer/GridContainer
@onready var scrollContainer = $Panel/ScrollContainer

var array = []
signal sendSong

func _ready():
	visible = false
	Globals.connect("changeArray", _set_array)
	#_make_buttons()
	_hide_scroll_bars()

func _hide_scroll_bars():
	scrollContainer.get_v_scroll_bar().modulate = Color(0, 0, 0, 0)
	scrollContainer.get_v_scroll_bar().scale.x = 0 
	scrollContainer.get_v_scroll_bar().scale.y = 0 

func _set_array():
	array = Globals.globalMusicArray
	_make_buttons()
	print("set array called")

func _make_buttons():
	#clear old for new
	for n in gridContainer.get_children():
		gridContainer.remove_child(n)

	for n in array.size():
		var button = recordButton.new()
		
		button.buttonInfo = array[n]
		button.buttonName = _song_title(array[n])
		button.mouse_entered.connect(_display_song_name.bind(button))
		button.pressed.connect(_play_song.bind(button))
		button.search.connect(_button_search.bind(button))
		
		gridContainer.add_child(button)

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

func _button_search(button):
	var name = button.buttonName.to_lower()
	
	#improved search function
	if name.find(Globals.searchWord.to_lower()) != -1:
		button.visible = true
	else:
		button.visible = false

	#makes sure that it there is something there
	if Globals.searchWord == "":
		button.visible = true

func _on_search_text_changed(new_text):
	Globals.searchWord = new_text
	Globals.emit_signal("forceSearch")

func _on_close_pressed():
	visible = false
