extends Node
const save_file = "user://save.data"
const save_playlist = "user://playlists.data"

var shuffle = true
var loop = false
signal newButton
signal changeNum
var playlist_dict := {}
#var folderArray = ["C:/Users/silve/Downloads/fartNoise3"]
var currentPlaylist = ["default playlist"]
#needs to save the array. Do that next time! Super close :)



func _save_playlist(currentButton, vbox):
	var file = FileAccess.open(save_playlist, FileAccess.WRITE)
	var playlist_data = _create_playlist_data(currentButton, vbox)
	file.store_var(playlist_data)
	file.close()#me

func _fix_order(dict):
	#var file = FileAccess.open(save_playlist, FileAccess.READ)
	var orderKeys = []
	var orderValues = []
	var testDict = {"PLAYLIST0": "stuff", "PLAYLIST5": "stuff2", "PLAYLIST4": "STUFF3"}

	testDict = dict
	#reorders dict and puts values in array 
	var i = 0
	for playlists in testDict:
		#var bacon = playlists
		var value = testDict[playlists]
		#print("playlist is, ", playlists)
		#print("value is ", value)
		var findNum = playlists.rfind('T')
		var title = playlists.right(-(findNum + 1))
		#print("num is ", title)
		
		var num = int(title)
		if num == i:
			#print("we good")
			orderKeys.append(playlists)
			orderValues.append(value)
		else:
			#print("we not good")
			playlists = str("PLAYLIST",i)
			orderKeys.insert(i, playlists)
			orderValues.insert(i, value)
			print(playlists)
		i += 1
		
	#remakes dict based on ordered values
	testDict = {}
	dict = {}
	for n in orderKeys.size():
		dict[orderKeys[n]] = orderValues[n]
	#print("testdict ", testDict)
	print("dict ",dict)
	#print("order keys is ", orderKeys)
	#print("order values is ", orderValues)
	#emit_signal("changeNum")
	playlist_dict = {}
	playlist_dict = dict
	return dict

func _load_playlist(hboxScroll):
	var file = FileAccess.open(save_playlist, FileAccess.READ)
	if FileAccess.file_exists(save_playlist):
		var data = file.get_var()
		var loaded_playlist_data = _fix_order(data)
		
		var i = 0
		for playlists in loaded_playlist_data:
			newButton.emit()
			var playlistdata = loaded_playlist_data[playlists]
			
			
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
	else:
		print("no playlist data")

func _song_title(string):
	var bacon = string
	var num = bacon.rfind('T')
	var title = bacon.right(-(num + 1))

	print(title)
	
	return title

func _remove_playlist(currentButton, vbox):
	if currentButton.array == []:
		var index = currentButton.get_index()
		var playlistName = str("PLAYLIST", index)
		playlist_dict.erase(playlistName)
		print("playlist deleted ", playlist_dict)
		
		var file = FileAccess.open(save_playlist, FileAccess.WRITE)
		var playlist_data = _fix_order(playlist_dict)
		#_sort(playlist_dict)
		file.store_var(playlist_data)
		file.close()#me

func _create_playlist_data(currentButton, vbox):
	
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

#save things
func _save():
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	var player_data = create_player_data()
	file.store_var(player_data)
	file.close()#me
	print("save done")

func create_player_data():
	var player_dict = {
		"LOOP": loop,
		"SHUFFLE": shuffle,
		"CURRENTPLAYLIST": currentPlaylist
	}
	return player_dict

func _load():
	var file = FileAccess.open(save_file, FileAccess.READ)
	if FileAccess.file_exists(save_file):
		var loaded_player_data = file.get_var()
		loop = loaded_player_data.LOOP
		shuffle = loaded_player_data.SHUFFLE
		currentPlaylist = loaded_player_data.CURRENTPLAYLIST
		file.close()
	else:
		_save()
	print("current playlist is ", currentPlaylist)

