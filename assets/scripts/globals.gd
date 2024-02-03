extends Node

var globalMusicArray = ["filler"] 
var nextSong = "filler"
signal changeArray

func _emit_change_array(array):
	globalMusicArray.clear()
	globalMusicArray.append_array(array)
	emit_signal("changeArray")
