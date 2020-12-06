extends Control

class_name SelectionUI

signal border_selected(path)
signal launch_border(path)

onready var start_script = OS.get_user_data_dir() + "/scripts/start.sh"
onready var stop_script = OS.get_user_data_dir() + "/scripts/stop.sh"

var border_path := ""
var p1_path := ""
var p2_path := ""

onready var settings: Settings = $"/root/Settings"

var output = []

func _ready():
	get_tree().get_root().set_transparent_background(false)
	OS.window_fullscreen = false
	OS.window_borderless = false
	OS.set_window_always_on_top(false)

	OS.window_size = Vector2(1024,600)
	OS.window_resizable = true

	OS.set_window_mouse_passthrough([]);

	_set_p1_dir(settings.val("paths", "p1"))
	_set_p2_dir(settings.val("paths", "p2"))
	_set_border_path(settings.val("paths", "border"))

	_update_running_state(1)
	_update_running_state(2)

func _update_running_state(player: int):
	if player == 1:
		$Container/P1/P1StartButton.disabled = _is_running(1) or p1_path == ""
		$Container/P1/P1StopButton.disabled = not _is_running(1)
	else:
		$Container/P2/P2StartButton.disabled = _is_running(2) or p2_path == ""
		$Container/P2/P2StopButton.disabled = not _is_running(2)

func _on_border_selected(path : String):
	emit_signal("border_selected", path)
	settings.update("paths", "border", path)
	_set_border_path(path)

func _set_border_path(path):
	border_path = path
	$BorderOpenDialog.current_path = border_path
	$Container/Border/BorderFile/BorderFileValue.text = border_path
	set_border_preview(border_path)


func set_border_preview(path):
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		return
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	$Container/Border/CenterContainer/BorderPreview.texture = texture

func _start_border():
	if border_path == "":
		$MessagePopUp.window_title = "No Border Selected"
		$MessagePopUp.dialog_text = "No Path is set for the Border"
		$MessagePopUp.popup()
		return
	$MessagePopUp.window_title = "How To Quit"
	$MessagePopUp.dialog_text = "There is a tiny 'x' button in the upper right corner to leave border mode."
	$MessagePopUp.popup()
	$MessagePopUp.connect("confirmed", self, "_actual_start_border")

func _actual_start_border():
	emit_signal("launch_border", border_path)

func _on_P1_dir_selected(dir):
	settings.update("paths", "p1", dir)
	_set_p1_dir(dir)

func _set_p1_dir(dir):
	p1_path = dir
	$Container/P1/P1Folder/P1FolderValue.text = p1_path
	$P1FolderOpenDialog.current_path = p1_path
	$Container/P1/P1StartButton.disabled = p1_path == ""

func _on_P2_dir_selected(dir):
	settings.update("paths", "p2", dir)
	_set_p2_dir(dir)

func _set_p2_dir(dir):
	p2_path = dir
	$Container/P2/P2Folder/P2FolderValue.text = p2_path
	$P2FolderOpenDialog.current_path = p2_path
	$Container/P2/P2StartButton.disabled = p2_path == ""

func _on_P1StartButton_pressed():
	if p1_path == "":
		$MessagePopUp.window_title = "Missing Path"
		$MessagePopUp.dialog_text = "No Path is set for Player 1"
		$MessagePopUp.popup()
		return
	_start_lightgun_service(1, p1_path, $Container/P1/P1StartButton, $Container/P1/P1StopButton)

func _on_P2StartButton_pressed():
	if p2_path == "":
		$MessagePopUp.window_title = "Missing Path"
		$MessagePopUp.dialog_text = "No Path is set for Player 2"
		$MessagePopUp.popup()
		return
	_start_lightgun_service(2, p2_path, $Container/P2/P2StartButton, $Container/P2/P2StopButton)

func _on_P1StopButton_pressed():
	_stop_lightgun_service(1, $Container/P1/P1StartButton, $Container/P1/P1StopButton)

func _on_P2StopButton_pressed():
	_stop_lightgun_service(2, $Container/P2/P2StartButton, $Container/P2/P2StopButton)

func _start_lightgun_service(player: int, path: String, start_button: Button, stop_button: Button):
	var code = OS.execute('/bin/bash', [ start_script, player, path ], true, output, true)
	stop_button.disabled = code != 0
	start_button.disabled = code == 0 or p1_path == ""
	if code != 0:
		$MessagePopUp.window_title = "Error Starting"
		$MessagePopUp.dialog_text = "Error code {code} \n {output}".format({"code": code, "output": "output"})
		$MessagePopUp.popup()
		print_debug(code)
		print_debug(output)

func _stop_lightgun_service(player: int, start_button: Button, stop_button: Button):
	var code = OS.execute('/bin/bash', [ stop_script, player ], true, output, true)
	stop_button.disabled = code == 0
	start_button.disabled = code != 0 or p1_path == ""
	if code != 0:
		$MessagePopUp.window_title = "Error Stopping"
		$MessagePopUp.dialog_text = "Error code {code} \n {output}".format({"code": code, "output": "output"})
		$MessagePopUp.popup()
		print_debug(code)
		print_debug(output)

func _is_running(player: int) -> bool:
	var lock = "/tmp/SindenLightgunP{player}.lock".format({"player": player})
	var file = File.new()
	return file.file_exists(lock)
