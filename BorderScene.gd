extends Node

class_name BorderScene

signal stop_border

func _ready():
	get_tree().get_root().set_transparent_background(true)
	OS.set_window_always_on_top(true)
	OS.window_resizable = false
	OS.window_fullscreen = false
	OS.window_borderless = true

	var screen_size = Vector2(1920, 1080)
	if OS.get_screen_count() == 1:
		screen_size = OS.get_screen_size()
	OS.set_window_size(screen_size)

	OS.window_position = Vector2.ZERO
	_setup_passthrough_and_exit()

func _setup_passthrough_and_exit():
	var a = $BackButton.rect_global_position
	var b = Vector2($BackButton.rect_global_position.x + $BackButton.rect_size.x, $BackButton.rect_global_position.y)
	var c = Vector2($BackButton.rect_global_position.x, $BackButton.rect_global_position.y + $BackButton.rect_size.y)
	var d = $BackButton.rect_global_position + $BackButton.rect_size
	OS.set_window_mouse_passthrough(PoolVector2Array([a, b, d, c]))

func set_border_image(path) -> bool:
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		return false
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	$BorderImage.texture = texture
	return true


func _on_BackButton_pressed():
	emit_signal("stop_border")
