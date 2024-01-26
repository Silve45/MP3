extends Node
const save_file = "user://save.data"
const save_playlist = "user://playlists.data"

var shuffle = true
var loop = false

#needs to save the array. Do that next time! Super close :)

func _save_playlist(scroll):
	var file = FileAccess.open(save_playlist, FileAccess.WRITE)
	var playlist_data = _create_playlist_data(scroll)
	file.store_var(playlist_data)
	file.close()#me

func _load_playlist(scroll):
	var file = FileAccess.open(save_playlist, FileAccess.READ)
	if FileAccess.file_exists(save_playlist):
		var loaded_playlist_data = file.get_var()
		var i = 0
		for playlists in loaded_playlist_data:
			var playlistdata = loaded_playlist_data[playlists]
			print(playlistdata)
			var setData = scroll.get_child(i)
			setData.array = playlistdata
			i += 1
			
		file.close()
		print(loaded_playlist_data)
	else:
		print("no playlist data")


func _create_playlist_data(scroll):
	var playlist_dict := {}
	for child in scroll.get_children():
		for n in scroll.get_child_count():
			var childName = str("PLAYLIST",n)
			playlist_dict[childName] = child.array
	print("playlist dict is ", playlist_dict)
	return playlist_dict


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


