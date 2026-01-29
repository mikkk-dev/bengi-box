extends Node2D

const NUMBER_SPRITES = [
	preload("uid://bual56rhqsumo"), 
	preload("uid://dpfrk50bdjnlu"), 
	preload("uid://cem65l85en2lh"), 
	preload("uid://ct2g0l6moi236"), 
	preload("uid://c5qjmdety5aqj"), 
	preload("uid://b152tyvmykcni"), 
	preload("uid://xhss2bw67dgj"), 
	preload("uid://c7q83jcu7qe1y"), 
	preload("uid://cknjako4t6mqq"), 
	preload("uid://di7a72yhmoelo")
]

const PAUSE_SPRITE = preload("uid://gmi843vjlk0j")
const PLAY_SPRITE = preload("uid://bpu3bqgcyllsq")


enum TimerMode {
	WORK,
	REST,
}

var _current_timer_mode: TimerMode = TimerMode.WORK

@onready var minute_1_sprite: TextureRect = %Minute1
@onready var minute_2_sprite: TextureRect = %Minute2
@onready var second_1_sprite: TextureRect = %Second1
@onready var second_2_sprite: TextureRect = %Second2
@onready var timer_sprite: TextureRect = %TimerImg
@onready var pause_button: Button = %PauseButton

@onready var pomodoro_timer: Timer = $PomodoroTimer
@onready var update_timer: Timer = $UpdateTimer
@onready var meow_player: AudioStreamPlayer2D = $MeowPlayer

@onready var activity_label: Label = %ActivityLabel
@onready var bengi_animator: AnimationPlayer = $Bengi/BengiAnimator
@onready var settings_window: Window = $SettingsWindow


func _ready() -> void:
	settings_window.close_requested.connect(settings_window.hide)
	pomodoro_timer.wait_time = max(ConfigManager.work_time * 60, 2) 


func _on_timer_click_area_click() -> void:
	print("bajo")
	meow_player.stop()
	activity_label.text = "Praca" if _current_timer_mode == TimerMode.WORK else "Przerwa"
	
	if not pomodoro_timer.time_left:
		bengi_animator.play("RESET")
		get_window().always_on_top = false
		if update_timer.is_stopped():
			update_timer.start()
		pomodoro_timer.start()
		
		var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(timer_sprite, "scale:x", 0.9, 0.1)
		tween.tween_property(timer_sprite, "scale:x", 1, 0.3)


func _on_update_timer_timeout() -> void:
	var seconds_left: int = int(pomodoro_timer.time_left)
	@warning_ignore("integer_division")
	var minutes: int = seconds_left / 60
	var seconds: int = seconds_left - minutes * 60
	
	if minutes < 10:
		minute_1_sprite.texture = NUMBER_SPRITES[0]
		minute_2_sprite.texture = NUMBER_SPRITES[minutes]
	else:
		@warning_ignore("integer_division")
		minute_1_sprite.texture = NUMBER_SPRITES[minutes / 10]
		minute_2_sprite.texture = NUMBER_SPRITES[minutes % 10]
	
	if seconds < 10:
		second_1_sprite.texture = NUMBER_SPRITES[0]
		second_2_sprite.texture = NUMBER_SPRITES[seconds]
	else:
		@warning_ignore("integer_division")
		second_1_sprite.texture = NUMBER_SPRITES[seconds / 10]
		second_2_sprite.texture = NUMBER_SPRITES[seconds % 10]


func _on_pomodoro_timer_timeout() -> void:
	pomodoro_timer.stop()
	bengi_animator.play("pulse")
	print("jajo")
	meow_player.play()
	get_window().always_on_top = true
	activity_label.text = "Kliknij zegar"
	
	if _current_timer_mode == TimerMode.WORK && ConfigManager.rest_time > 0:
		_current_timer_mode = TimerMode.REST
		pomodoro_timer.wait_time = max(ConfigManager.rest_time * 60, 1)
		activity_label.modulate = Color.SLATE_BLUE
	
	elif _current_timer_mode == TimerMode.REST && ConfigManager.work_time > 0:
		_current_timer_mode = TimerMode.WORK
		pomodoro_timer.wait_time = max(ConfigManager.work_time * 60, 1)
		activity_label.modulate = Color.WHITE


func _on_exit_button_pressed() -> void:
	ConfigManager.save_config()
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	settings_window.show()


func _on_timer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.is_pressed():
				_on_timer_click_area_click()


func _on_pause_button_pressed() -> void:
	if not pomodoro_timer.time_left: return
	
	if pomodoro_timer.paused:
		pomodoro_timer.paused = false
		pause_button.icon = PAUSE_SPRITE
	else:
		pomodoro_timer.paused = true
		pause_button.icon = PLAY_SPRITE


func _on_next_button_pressed() -> void:
	_on_pomodoro_timer_timeout()
