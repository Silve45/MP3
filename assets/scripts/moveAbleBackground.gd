extends ColorRect

var following = false
var dragging_start_position = Vector2i()


func _on_gui_input(event):
	if event is InputEventMouseButton:
		following = !following
		dragging_start_position = get_local_mouse_position()

func _process(delta):
	if following:
		DisplayServer.window_set_position(DisplayServer.window_get_position() + Vector2i(get_global_mouse_position()) - Vector2i(dragging_start_position))
		print(DisplayServer.window_get_position())
