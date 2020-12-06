extends Node

const SAVE_PATH = "user://settings.cfg"

var last_reload

signal error_loading
signal loaded

var _config_file = ConfigFile.new()
var _settings = {
	"paths": {
		"border": "",
		"p1": "",
		"p2": "",
		"p3": "",
		"p4": ""
	}
}

func _ready():
	# warning-ignore:return_value_discarded
	reload()

func save_all():
	for section in _settings.keys():
		for key in _settings[section].keys():
			_config_file.set_value(section, key, _settings[section][key])
	_config_file.save(SAVE_PATH)

func reload() -> bool:
	last_reload = _config_file.load(SAVE_PATH)
	if last_reload != OK:
		#print("Error loading the settings, Error code: %s" % last_reload)
		emit_signal("error_loading")
		return false

	for category in _settings.keys():
		for key in _settings[category].keys():
			var default = _settings[category][key]
			_settings[category][key] = _config_file.get_value(category, key, default)
	emit_signal("loaded")
	return true

func val(category, key):
	return _settings[category][key]

func update(category: String, key: String, value, save_immediately: = true):
	_settings[category][key] = value
	if save_immediately:
		_config_file.set_value(category, key, value)
		_config_file.save(SAVE_PATH)
