extends Node

signal config_ready
signal config_updated

var work_time: int = 25:
	set(val):
		work_time = clamp(val, 0, 59)
		config_updated.emit()
var rest_time: int = 5:
	set(val):
		rest_time = clamp(val, 0, 59)
		config_updated.emit()
var borderless: bool:
	get():
		return _window.borderless

var _window: Window

func _ready() -> void:
	_window = get_window()

	get_tree().set_auto_accept_quit(false)
	_window.close_requested.connect(
		func():
			save_config()
			get_tree().quit()
	)
	load_config()


func set_borderless(val: bool) -> void:
	_window.borderless = val
	if val:
		_window.size = Vector2(_window.size.x - 8, _window.size.y - 40)
		_window.position += Vector2i(8, 32)
	else:
		_window.size = Vector2(_window.size.x + 8, _window.size.y + 40)
		_window.position -= Vector2i(8, 32)


func load_config() -> void:
	var config := ConfigFile.new()
	
	var err = config.load("user://bengi-box.cfg")
	
	if err != OK:
		return
	
	_window.position = Vector2(config.get_value("Position", "position_x"), config.get_value("Position", "position_y"))
	if config.get_value("Misc", "borderless"):
		set_borderless(true)
	
	work_time = config.get_value("Timer", "work_time")
	rest_time = config.get_value("Timer", "rest_time")
	config_ready.emit()


func save_config() -> void:
	var config := ConfigFile.new()
	
	config.set_value("Timer", "work_time", work_time)
	config.set_value("Timer", "rest_time", rest_time)
	config.set_value("Position", "position_x", _window.position.x)
	config.set_value("Position", "position_y", _window.position.y)
	config.set_value("Misc", "borderless", _window.borderless)
	
	config.save("user://bengi-box.cfg")
