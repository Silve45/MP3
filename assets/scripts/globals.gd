extends Node

var globalMusicArray = ["filler"] 
var nextSong = "filler"
var searchWord = ""
signal changeArray
signal forceSearch

func _emit_change_array(array):
	globalMusicArray.clear()
	globalMusicArray.append_array(array)
	#print("globals music array is ", globalMusicArray)
	emit_signal("changeArray")
