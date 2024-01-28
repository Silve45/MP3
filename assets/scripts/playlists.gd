extends Control
#@onready var label = $Panel/ScrollContainer2/VBoxContainer/Label

@onready var hboxScroll = $ScrollContainer/HBoxContainer

@onready var vboxScroll = $buttonPlaylists/ScrollContainer2/VBoxContainer
@onready var lineedit = $buttonPlaylists/ScrollContainer2/VBoxContainer/LineEdit
@onready var buttonPlaylists = $buttonPlaylists
#@onready var addNewButton = $"ScrollContainer/HBoxContainer/add new button"

var playlistArray = ["filler"]
var currentArray = playlistArray # by default
var currentButton
var addButton
var addButtonON = false

func _ready():
	SaveData.connect("newButton", _add_playlist_button)
	
	SaveData._load_playlist(hboxScroll)
	_make_add_button()
	

func _make_add_button():
	addButton = Button.new()
	hboxScroll.add_child(addButton)
	addButton.custom_minimum_size.x = 300
	addButton.custom_minimum_size.y = 300
	addButton.add_theme_font_size_override("font_size", 200)
	addButton.theme = load("res://resources/themes/blueButtonTheme.tres")
	addButton.text = "+"
	addButtonON = true
	addButton.connect("pressed",_on_add_new_button_pressed)
	_add_button_index_last()

func _add_button_index_last():
	hboxScroll.move_child(addButton, hboxScroll.get_child_count())

func _add_playlist_button():
	var button2 = playlistButton.new()
	hboxScroll.add_child(button2)
	if addButtonON == true:
		_add_button_index_last()
	var num
	num = button2.get_index()
	#this should fix empty buttons
	
	button2.pressed.connect(_playlist_edit_open.bind(button2))
	button2.text = str(num)


func _playlist_edit_open(button2):
	#print(button2.array)
	currentButton = button2
	currentArray = button2.array
	_ready_playlist_array(button2.array)
	buttonPlaylists.visible = true

func _on_add_new_button_pressed():
	_add_playlist_button()
	_add_button_index_last()


func _on_line_edit_text_submitted(new_text):
	_add_playlist_array(currentArray, new_text)

func _add_playlist_array(array,new_text):
	array.append(new_text)
	var newButton = Button.new()
	newButton.add_to_group("buttons")
	newButton.pressed.connect(_button_press.bind(newButton))
	newButton.set_text(new_text)
	vboxScroll.add_child(newButton)
	vboxScroll.move_child(lineedit, vboxScroll.get_child_count())
	lineedit.text = ""
	#maybe save on a current button
	SaveData._save_playlist(currentButton, vboxScroll)
	#print(array)

func _ready_playlist_array(array):
	if array.size() > 0:
		for n in array.size():
			var text = array[n - 1]
			var newButton = Button.new()
			newButton.add_to_group("buttons")
			newButton.pressed.connect(_button_press.bind(newButton))
			newButton.set_text(text)
			vboxScroll.add_child(newButton)
			vboxScroll.move_child(lineedit, vboxScroll.get_child_count())
			lineedit.text = ""


func _button_press(newButton): #array might break it, switch back to playlist array maybe
	print(newButton.text)
	if currentButton.array.has(newButton.text):
		#this removes folder
		var index = currentButton.array.find(newButton.text)
		print("index is, ", index)
		currentButton.array.remove_at(index)
		print("current button array is ", currentButton.array)

		newButton.queue_free()

		print(vboxScroll.get_child_count())
		await newButton.tree_exited
		SaveData._save_playlist(currentButton, vboxScroll)



func _on_close_pressed():
	buttonPlaylists.visible = false
	#removes children so there are no duplicate buttons
	for child in vboxScroll.get_children():
		if child.is_in_group("buttons"):
			child.queue_free()
	#if currentButton.array == []:
		#currentButton.queue_free()

