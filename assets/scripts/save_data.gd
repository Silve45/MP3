extends Node
const save_file = "user://save.data"

var shuffle = true
var loop = false

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


