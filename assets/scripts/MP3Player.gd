extends Control

@onready var music = $music
@onready var progressBar = $ProgressBar
@onready var songLabel = $ScrollContainer/songLabel
@onready var scrollContainer = $ScrollContainer
@onready var scrollH = scrollContainer.get_h_scroll_bar()
@onready var scrollTimer = $scrollTimer
@onready var volumeSlider = $volume
#@onready var _bus := AudioServer.get_bus_index("Music")

@onready var sound = AudioStreamMP3.new()

signal killTween

var testSong = "C:/Users/silve/Documents/0-Kdenlive/newClipsFolder/music/OtherSongs/slowPaced/sans..mp3"
var testFolder = "C:/Users/silve/Documents/0-Kdenlive/newClipsFolder/music/OtherSongs/slowPaced/"
var musicArray = []
var musicGarabage = []

func _ready():
	SaveData._load()
	get_dir_contents(musicArray, testFolder)
	_check_loop()
	#_hide_scroll_bars()

#just makes it full screen if I press f
func _input(event):#doesn't work right now0
	if event.is_action_pressed("debug"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	#print("volume is ", AudioServer.get_bus_volume_db(_bus))

func _on_shuffle_on_start_pressed():
	_shuffle_on_start()

func _shuffle_on_start():
	if SaveData.shuffle == true:
		SaveData.shuffle = false
		print("SOS off")
	else:
		SaveData.shuffle = true
		musicArray.shuffle()
		print("SOS on")
	SaveData._save()

func _hide_scroll_bars():
	scrollContainer.get_h_scroll_bar().modulate = Color(0, 0, 0, 0)
	scrollContainer.get_h_scroll_bar().scale.x = 0 
	scrollContainer.get_h_scroll_bar().scale.y = 0 

func _song_title(string):
	var bacon = string
	var num = bacon.rfind('/')
	var title = bacon.right(-(num + 1))
	var num2 = title.rfind('.')
	var newTitle = title.left(num2)
	#print(newTitle)
	
	return newTitle


func _on_line_edit_text_submitted(new_text):
	#this will clear the old array
	if new_text == "":
		testFolder = "C:/Users/silve/Documents/0-Kdenlive/newClipsFolder/music/OtherSongs/slowPaced/"
	else:
		musicArray.clear()
		
		var text = new_text.replace("\\", "/")
		var text2 = text.replace('"', "")
		testFolder = text2
		#print(text2)
		get_dir_contents(musicArray, testFolder)

func _process(_delta):
	progressBar.value = music.get_playback_position()

func _on_play_pressed():
	if music.stream_paused == true:
		music.stream_paused = false
	else:
		_play_test_song()

func _on_foward_pressed():
	_play_next_song()



func _on_pause_pressed():
	if music.stream_paused == false:
		music.stream_paused = true
	else:
		music.stream_paused = false


func _on_reset_songs_pressed():
	_re_add_songs()

func _on_shuffle_pressed():
	_suffle()#only this here

func _suffle():
	musicGarabage.insert(0, musicArray[0])
	musicArray.shuffle()
	if musicArray.size() != 0:
		_set_music()
		music.play()
	elif musicArray.size() == 0:
		_re_add_songs()


func _on_next_pressed():
	print(" music garbage is ", musicGarabage)
	_play_next_song()

func _on_back_pressed():
	print(" music garbage is ", musicGarabage)
	_play_previous_song()

func _on_refresh_song_pressed():
	_re_add_songs()



func _play_previous_song():
	if musicGarabage.size() != 0:
		musicArray.insert(0, musicGarabage[0])
		#musicArray.append(musicGarabage[0])
		musicGarabage.remove_at(0)
		_set_music()
		music.play()
	elif musicGarabage.size() == 0:
		print("no previous song")

func _set_music():
	#print(musicGarabage)
	if musicArray.size() == 0:
		_re_add_songs()
	music.stream = load_mp3(musicArray[0])
	_song_title(musicArray[0])
	songLabel.set_text(_song_title(musicArray[0]))
	#print("current song is, ", _song_title(musicArray[0]))
	if musicGarabage.size() != 0:
		print("last song is, ", _song_title(musicGarabage[0]))
	
	_resetScroll()
	var length = music.stream.get_length()
	progressBar.max_value = length

func _on_scroll_timer_timeout():
	_scroll()

func _scroll():
	var maxValue = scrollH.max_value
	var tween = get_tree().create_tween()
	tween.tween_property(scrollH, "value", maxValue, 5)
	tween.connect("finished",_resetScroll)
	await killTween#waits to see of kill tween is emitted
	tween.kill()

func _resetScroll():
	emit_signal("killTween")
	scrollH.value = 0
	scrollTimer.start()

func _play_test_song():
	_set_music()
	music.play()

func _on_music_finished():
	musicGarabage.insert(0, musicArray[0])
	musicArray.remove_at(0)
	if musicArray.is_empty():
		print("redo")
		_re_add_songs()
	_set_music()
	music.play()

	#print(musicArray.size())

func _play_next_song():
	if musicArray.size() != 0:
		#print("next is, ", musicArray )
		musicGarabage.insert(0, musicArray[0])
		musicArray.remove_at(0)
		_set_music()
		music.play()
	elif musicArray.size() == 0:
		_re_add_songs()

func _re_add_songs():
	musicArray.append_array(musicGarabage)
	musicGarabage.clear()
	#musicArray.shuffle()# maybe move this to shuffle
	_set_music()
	music.play()



func _on_loop_pressed():
	if sound != null:
		if SaveData.loop == true:
			sound.loop = false
			SaveData.loop = false
			_check_loop()
		else:
			sound.loop = true
			SaveData.loop = true
			_check_loop()
		SaveData._save()
	else:
		print("sound is null")

func _check_loop():
	if SaveData.loop == true:
		$buttonsContainer/loop.icon = load("res://assets/sprites/loop.png")
		#print("looping true")
		$ButtonsContainer/loop.text = "loop true"
	else:
		$buttonsContainer/loop.icon = load("res://assets/sprites/loopOff.png")
		#print("looping off")
		$ButtonsContainer/loop.text = "loop off"


#____________________________
func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	sound = AudioStreamMP3.new()#this fixed the crashing problem
	sound.data = file.get_buffer(file.get_length())
	#sound.loop = true
	return sound


func get_dir_contents( array:Array, rootPath: String):
	var levels = []
	var directories = []
	var dir = DirAccess.open(rootPath)

	if dir:
		dir.list_dir_begin()
		_add_dir_contents(dir, levels, directories)
	else:
		push_error("An error occurred when trying to access the path.")

	array.append_array(levels)
	if SaveData.shuffle == true:
		array.shuffle()
		print("shuffling")
	else:
		print("not shuffling")
	#print(array)
	return [levels, directories]

func _add_dir_contents(dir: DirAccess, files: Array, directories: Array):
	var file_name = dir.get_next()

	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name

		if dir.current_is_dir():
#			print("Found directory: %s" % path)
#			var subDir = Directory.new()
			var subDir = DirAccess.open(path)
			subDir.list_dir_begin()
			directories.append(path)
			_add_dir_contents(subDir, files, directories)
		else:
#			print("Found file: %s" % path)
			if path.contains(".mp3"):
				files.append(path)

		file_name = dir.get_next()

	dir.list_dir_end()

