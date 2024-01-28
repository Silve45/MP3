extends Node
const save_file = "user://save.data"
const save_playlist = "user://playlists.data"

var shuffle = true
var loop = false
signal newButton
var playlist_dict := {}
#needs to save the array. Do that next time! Super close :)

func _save_playlist(currentButton, vbox):
	var file = FileAccess.open(save_playlist, FileAccess.WRITE)
	var playlist_data = _create(currentButton, vbox)
	file.store_var(playlist_data)
	file.close()#me

func _load_playlist(hboxScroll):
	var file = FileAccess.open(save_playlist, FileAccess.READ)
	if FileAccess.file_exists(save_playlist):
		var loaded_playlist_data = file.get_var()
		var i = 0
		for playlists in loaded_playlist_data:
			newButton.emit()
			var playlistdata = loaded_playlist_data[playlists]
			#print(playlistdata)
			
			print("playlist is ", playlists)
			var name_check = str("PLAYLIST", i)

			var indexCheck = int(_song_title(name_check))
			
			var setData = hboxScroll.get_child(i)

			
			if name_check == playlists:
				setData.array = playlistdata
				print("check complete ", indexCheck)
			print("loop ", i)
			i += 1
			
		file.close()
		print(loaded_playlist_data)
		playlist_dict = loaded_playlist_data #makes sure data is good!
		#print("playlist dict is ", playlist_dict)
	else:
		print("no playlist data")

func _song_title(string):
	var bacon = string
	var num = bacon.rfind('T')
	var title = bacon.right(-(num + 1))

	print(title)
	
	return title



func _create(currentButton, vbox):
	
	#get button positon and name? to save on playlist
	#save array of text from vboxcontainer and  on to the (hbox)currentbuttons array
	#save dictionary of that hboxbutton(position)
	
	#this is the array to save
	var array = []
	for child in vbox.get_children():
		if child.is_in_group("buttons"):
			array.append(child.text)
			currentButton.array = array
			print(currentButton.array)
	
	var index = currentButton.get_index()
	var playlistName = str("PLAYLIST", index)
	playlist_dict[playlistName] = currentButton.array
	print(playlist_dict)
	return playlist_dict
		#var test = $buttonPlaylists/ScrollContainer2/VBoxContainer/LineEdit.get_index()

#save things
func _save():
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	var player_data = create_player_data()
	file.store_var(player_data)
	file.close()#me


func create_player_data():
	var player_dict = {
		"LOOP": loop,
		"SHUFFLE": shuffle
	}
	return player_dict

func _load():
	var file = FileAccess.open(save_file, FileAccess.READ)
	if FileAccess.file_exists(save_file):
		var loaded_player_data = file.get_var()
		loop = loaded_player_data.LOOP
		shuffle = loaded_player_data.SHUFFLE
		file.close()
	else:
		_save()


