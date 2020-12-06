extends Control

var selection_scene : PackedScene = preload("res://SelectionUI.tscn")
var border_scene : PackedScene = preload("res://Border.tscn")

onready var start_script = OS.get_user_data_dir() + "/scripts/start.sh"
onready var stop_script = OS.get_user_data_dir() + "/scripts/stop.sh"

var selector_pos : Vector2

func _ready():
	_setup_scripts()
	selector_pos = OS.window_position
	_on_return_to_menu()

func _setup_scripts():
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir("scripts")
	dir.copy("res://start.sh", "user://scripts/start.sh")
	dir.copy("res://stop.sh", "user://scripts/stop.sh")
	var code = OS.execute('chmod', ['+x', start_script])
	if code != 0:
		print_debug('chmodding start script: ', code)
	code = OS.execute('chmod', ['+x', stop_script])
	if code != 0:
		print_debug('chmodding stop script: ', code)



func _on_return_to_menu():
	delete_children(self)
	var scene : SelectionUI = selection_scene.instance()
	add_child(scene)

	OS.window_position = selector_pos
	# warning-ignore:return_value_discarded
	scene.connect("launch_border", self, "_on_launch_border")

func _on_launch_border(path :String):
	selector_pos = OS.window_position
	delete_children(self)
	var scene : BorderScene = border_scene.instance()
	# warning-ignore:return_value_discarded
	scene.set_border_image(path)
	add_child(scene)

	# warning-ignore:return_value_discarded
	scene.connect("stop_border", self, "_on_return_to_menu")

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
