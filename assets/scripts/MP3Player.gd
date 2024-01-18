extends Control

@onready var music = $music
@onready var progressBar = $ProgressBar
@onready var songLabel = $ScrollContainer/songLabel
@onready var scrollContainer = $ScrollContainer
@onready var scrollH = scrollContainer.get_h_scroll_bar()
@onready var scrollTimer = $scrollTimer
signal killTween

var testSong = "C:/Users/silve/Documents/0-Kdenlive/newClipsFolder/music/OtherSongs/slowPaced/sans..mp3"
var testFolder = "C:/Users/silve/Documents/0-Kdenlive/newClipsFolder/music/OtherSongs/slowPaced/"
var musicArray = []
var musicGarabage = []

func _ready():
	SaveData._load()
	get_dir_contents(musicArray, testFolder)
	#_hide_scroll_bars()

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
	print(newTitle)
	songLabel.set_text(newTitle)


func _on_line_edit_text_submitted(new_text):
	#this will clear the old array
	if new_text == "":
		testFolder = "C:/Users/silve/Documents/0-Kdenlive/newClipsFolder/music/OtherSongs/slowPaced/"
	else:
		musicArray.clear()
		
		var text = new_text.replace("\\", "/")
		var text2 = text.replace('"', "")
		testFolder = text2
		print(text2)
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

func _on_back_pressed():
	_play_previous_song()

func _on_pause_pressed():
	if music.stream_paused == false:
		music.stream_paused = true
	else:
		music.stream_paused = false


func _on_reset_songs_pressed():
	_re_add_songs()

func _on_shuffle_pressed():
	musicArray.shuffle()



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
	print(musicGarabage)
	if musicArray.size() == 0:
		_re_add_songs()
	music.stream = load_mp3(musicArray[0])
	_song_title(musicArray[0])
	
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
		#print("array is NOT Zero")
		musicGarabage.insert(0, musicArray[0])
		musicArray.remove_at(0)
		_set_music()
		music.play()
	elif musicArray.size() == 0:
		#print("array is Zero")
		_re_add_songs()

func _re_add_songs():
	musicArray.append_array(musicGarabage)
	musicGarabage.clear()
	#musicArray.shuffle()# maybe move this to shuffle
	_set_music()
	music.play()


var sound
func _on_loop_pressed():
	if sound != null:
		if SaveData.loop == true:
			sound.loop = false
			SaveData.loop = false
			print("looping off")
			$ButtonsContainer/loop.text = "loop off"
		else:
			sound.loop = true
			SaveData.loop = true
			print("looping on")
			$ButtonsContainer/loop.text = "loop on"
		SaveData._save()
	else:
		print("sound is null")

#____________________________
func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	sound = AudioStreamMP3.new()
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



