extends Control

@onready var songNameLabel = $songName
@onready var gridContainer = $Panel/ScrollContainer/GridContainer

var array = []
signal sendSong

func _ready():
	visible = false
	Globals.connect("changeArray", _set_array)
	_make_buttons()

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
		#
		#if currentHboxContainer.get_child_count() < 5:
			#currentHboxContainer.add_child(button)
		#else:
			#_make_new_hbox()
			#currentHboxContainer.add_child(button)

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

	var nameArray = []
	for n in button.buttonName.length():
		nameArray.append(button.buttonName[n].to_lower())
	
	var searchArray = []
	for n in Globals.searchWord.length():
		searchArray.append(Globals.searchWord[n].to_lower())

	
	for n in searchArray.size():
		if nameArray[n] != searchArray[n]:
			button.visible = false
			break
		else:
			button.visible = true
		
	if Globals.searchWord == "":
		button.visible = true


func _on_search_text_changed(new_text):
	Globals.searchWord = new_text
	Globals.emit_signal("forceSearch")



func _on_close_pressed():
	visible = false


