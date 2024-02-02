class_name toast
extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	#$toastVisiblityTimer
	custom_minimum_size.y = 45
	theme = load("res://resources/themes/toastTheme.tres")
	horizontal_alignment = 1



	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1
	timer.autostart = false
	timer.connect("timeout", _timeout )
	add_child(timer)
	timer.start()

func _toast(_text):
	set_text(_text)

func _timeout():
	var tween = get_tree().create_tween()
	var color : Color
	color.r = 1
	color.g = 1
	color.b = 1 
	color.a = 0
	tween.tween_property($".", "modulate", color , 2)
	await tween.finished
	queue_free()
