extends Control
#@onready var label = $Panel/ScrollContainer2/VBoxContainer/Label

@onready var hboxScroll = $ScrollContainer/HBoxContainer

@onready var vboxScroll = $buttonPlaylists/ScrollContainer2/VBoxContainer
@onready var lineedit = $buttonPlaylists/ScrollContainer2/VBoxContainer/LineEdit
@onready var buttonPlaylists = $buttonPlaylists

var playlistArray = ["a","cdcd"]
var currentArray = playlistArray # by default

func _ready():
	_add_playlist_button()
	_add_playlist_button()
	_add_playlist_button()

	SaveData._load_playlist(hboxScroll)


func _add_playlist_button():
	var button2 = playlistButton.new()
	hboxScroll.add_child(button2)
	var num = button2.get_index() + 1
	button2.pressed.connect(_playlist_edit_open.bind(button2))
	button2.text = str(num)


func _playlist_edit_open(button2):
	print(button2.array)
	currentArray = button2.array
	_ready_playlist_array(button2.array)
	buttonPlaylists.visible = true


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
	SaveData._save_playlist(hboxScroll)
	print(array)

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
	if currentArray.has(newButton.text):
		#this removes folder
		var index = currentArray.find(newButton.text)
		currentArray.remove_at(index)
		newButton.queue_free()
		print(currentArray)


func _on_close_pressed():
	buttonPlaylists.visible = false
	#removes children so there are no duplicate buttons
	for child in vboxScroll.get_children():
		if child.is_in_group("buttons"):
			child.queue_free()
