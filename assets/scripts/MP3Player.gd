extends Control

@onready var music = $music
@onready var songLabel = $ScrollContainer/songLabel
@onready var scrollContainer = $ScrollContainer
@onready var smallSongLabel = $smallMode/ScrollContainer/songLabel
@onready var smallScrollContainer = $smallMode/ScrollContainer
@onready var scrollH = scrollContainer.get_h_scroll_bar()
@onready var smallScrollH = smallScrollContainer.get_h_scroll_bar()
@onready var scrollTimer = $scrollTimer
@onready var songSlider = $songSlider
@onready var toastContainer = $toastContainer
@onready var uisongDisplay = $"ui-SongDisplay"
@onready var smallModeDisplay = $smallMode

@onready var sound = AudioStreamMP3.new()

signal killTween

var folderArray = ["C:/Users/silve/Documents/0-Kdenlive/newClipsFolder/music/OtherSongs/slowPaced/"]
var musicArray = []
var musicGarabage = []
var smallMode = false


func _ready():
	$playlists.connect("changeDisplay", _change_playlist_display_number)#just connects for later use
	$playlists.connect("folders", _get_folders)#just connects for later use
	$"ui-SongDisplay".connect("sendSong",_play_selected_song )#just connects for later use
	SaveData._load()#loads save data
	
	_get_folders_ready()
	_ready_shuffle()
	_check_loop()
	_check_play_on_switch()
	_hide_scroll_bars()
	_change_playlist_display_number()

func _process(_delta):
	if slider_moving == false:
		songSlider.value = music.get_playback_position()


#all the button press functions
func _on_shuffle_on_start_pressed():
	_shuffle_on_start()

func _on_full_screen_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_small_mode_pressed():
	_small_mode_set()

func _on_undo_small_mode_pressed():
	_small_mode_set()

func _on_play_pressed():
	if music.stream_paused == true:
		music.stream_paused = false
	else:
		_play_test_song()

func _on_small_pause_pressed():
	if music.stream_paused == false:
		music.stream_paused = true
	else:
		music.stream_paused = false
	
	if music.stream == null:
		_play_test_song()

func _on_pause_pressed():
	if music.stream_paused == false:
		music.stream_paused = true
	else:
		music.stream_paused = false

func _on_shuffle_pressed():
	_shuffle()#only this here

func _on_next_pressed():
	print(" music garbage is ", musicGarabage)
	_play_next_song()

func _on_back_pressed():
	print(" music garbage is ", musicGarabage)
	_play_previous_song()

func _on_refresh_song_pressed():
	_re_add_songs()

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

func _on_display_songs_pressed():
	uisongDisplay.visible = true

func _on_display_playlist_pressed():
	$playlists.visible = true
	print("display")

func _on_settings_button_pressed():
	$settingsPanel.visible = true

func _on_close_settings_pressed():
	$settingsPanel.visible = false



#start of music slider
var slider_moving = false
func _on_song_slider_drag_started():
	slider_moving = true

func _on_song_slider_drag_ended(value_changed):
	slider_moving = false

func _on_song_slider_value_changed(value):
	if slider_moving == true:
		music.seek(value)
#end of music slider

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	print("volume is ", $VolumeSlider.get_value())

func _on_play_song_on_playlist_switch_pressed():
	if SaveData.playOnSwitch == true:
		SaveData.playOnSwitch = false
		_check_play_on_switch()
		SaveData._save()
	else:
		SaveData.playOnSwitch = true
		_check_play_on_switch()
		SaveData._save()

func _check_play_on_switch():
	if SaveData.playOnSwitch == true:
		$settingsPanel/VBoxContainer/hbox3/TextureRect.modulate = "99e550"
	else:
		$settingsPanel/VBoxContainer/hbox3/TextureRect.modulate = "f25a5a"

#functions (Out of order right now)

func _small_mode_set():
	if smallMode == false:
		smallModeDisplay.visible = true
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152/4, 648/4))
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
		DisplayServer.window_set_flag(0, true)
		smallMode = true
	else:
		smallModeDisplay.visible = false
		DisplayServer.window_set_size(Vector2i(1152, 648))
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)
		DisplayServer.window_set_flag(0, false)
		smallMode = false



func _change_playlist_display_number():
	$displayPlaylist.text = str(SaveData.currentNum)

func _ready_shuffle():
	if SaveData.shuffle == true:
		musicArray.shuffle()
		$settingsPanel/VBoxContainer/hbox/TextureRect.modulate = "99e550"
		print("shuffling")
	else:
		$settingsPanel/VBoxContainer/hbox/TextureRect.modulate = "f25a5a"
		print("not shuffling")


func _get_folders_ready():#this is the old one, so I can have my cake and eat it too
	for n in SaveData.currentPlaylist.size():
		if musicArray.size() > 0:
			musicArray.clear()
		if musicGarabage.size() > 0: #fixes bug where old song could still be played when swithing playist
			musicGarabage.clear()
		
		get_dir_contents(musicArray, SaveData.currentPlaylist[n])
		
		Globals._emit_change_array(musicArray)

func _get_folders():
	for n in SaveData.currentPlaylist.size():
		if musicArray.size() > 0:
			musicArray.clear()
		if musicGarabage.size() > 0: #fixes bug where old song could still be played when swithing playist
			musicGarabage.clear()
		
		get_dir_contents(musicArray, SaveData.currentPlaylist[n])
		_force_song_change() #should fix problem of switching playlists
		
		Globals._emit_change_array(musicArray)

func _force_song_change():#like set music but only called this for this
	music.stream = load_mp3(musicArray[0])
	if SaveData.playOnSwitch == true:
		music.play()
	_song_title(musicArray[0])
	songLabel.set_text(_song_title(musicArray[0]))
	smallSongLabel.set_text(_song_title(musicArray[0]))

func _shuffle_on_start():#for shuffle on start button
	if SaveData.shuffle == true:
		SaveData.shuffle = false
		$settingsPanel/VBoxContainer/hbox/TextureRect.modulate = "f25a5a"
		print("SOS off")
	else:
		SaveData.shuffle = true
		$settingsPanel/VBoxContainer/hbox/TextureRect.modulate = "99e550"
		musicArray.shuffle()
		print("SOS on")
	SaveData._save()

func _hide_scroll_bars():
	#old
	#scrollContainer.get_h_scroll_bar().modulate = Color(0, 0, 0, 0)
	#scrollContainer.get_h_scroll_bar().scale.x = 0 
	#scrollContainer.get_h_scroll_bar().scale.y = 0 
	scrollContainer.set_horizontal_scroll_mode(3)
	smallScrollContainer.set_horizontal_scroll_mode(3)

func _song_title(string):
	var bacon = string
	var num = bacon.rfind('/')
	var title = bacon.right(-(num + 1))
	var num2 = title.rfind('.')
	var newTitle = title.left(num2)
	return newTitle

func _shuffle():
	musicGarabage.insert(0, musicArray[0])
	musicArray.shuffle()
	if musicArray.size() != 0:
		_set_music()
		music.play()
	elif musicArray.size() == 0:
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
	smallSongLabel.set_text(_song_title(musicArray[0]))
	#print("current song is, ", _song_title(musicArray[0]))
	if musicGarabage.size() != 0:
		print("last song is, ", _song_title(musicGarabage[0]))
	
	_resetScroll()
	var length = music.stream.get_length()
	songSlider.max_value = length

func _on_scroll_timer_timeout():
	_scroll()

func _scroll():
	if smallMode == false:
		var maxValue = scrollH.max_value
		var tween = get_tree().create_tween()
		tween.tween_property(scrollH, "value", maxValue, 5)
		tween.connect("finished",_resetScroll)
		await killTween#waits to see of kill tween is emitted
		tween.kill()
	else:
		var maxValue = smallScrollH.max_value
		var tween = get_tree().create_tween()
		tween.tween_property(smallScrollH, "value", maxValue, 5)
		tween.connect("finished",_resetScroll)
		await killTween#waits to see of kill tween is emitted
		tween.kill()

func _resetScroll():
	emit_signal("killTween")
	scrollH.value = 0
	smallScrollH.value = 0
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

func _play_selected_song():
	if musicArray.size() != 0:
		#print("next is, ", musicArray )
		
		musicGarabage.insert(0, musicArray[0])
		musicArray.remove_at(0)
		musicArray.insert(0, Globals.nextSong)
		_set_music()
		music.play()

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
	_set_music()
	music.play()

func _check_loop():
	if SaveData.loop == true:
		print("looping true")
		$settingsPanel/VBoxContainer/hbox2/TextureRect.modulate = "99e550"
	else:
		print("looping off")
		$settingsPanel/VBoxContainer/hbox2/TextureRect.modulate = "f25a5a"



#error message toasts
func _toast(text):
	var toastMake = toast.new()
	toastMake._toast(text)
	toastContainer.add_child(toastMake)

#____________________________
#gets the mp3 files from the path
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
		_toast(str(rootPath, " does not exist"))

	array.append_array(levels)
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







