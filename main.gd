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

enum TimerMode {
	WORK,
	REST,
}

var _current_timer_mode: TimerMode = TimerMode.REST

@onready var minute_1_sprite: Sprite2D = $Timer/Minute1
@onready var minute_2_sprite: Sprite2D = $Timer/Minute2
@onready var second_1_sprite: Sprite2D = $Timer/Second1
@onready var second_2_sprite: Sprite2D = $Timer/Second2
@onready var timer_sprite: AnimatedSprite2D = $Timer

@onready var pomodoro_timer: Timer = $PomodoroTimer
@onready var timer_click_area: ClickArea = $Timer/ClickArea
@onready var meow_player: AudioStreamPlayer2D = $MeowPlayer

@onready var activity_label: Label = $CanvasLayer/Control/ActivityLabel
@onready var bengi_animator: AnimationPlayer = $Bengi/BengiAnimator
@onready var settings_window: Window = $SettingsWindow


func _ready() -> void:
	timer_click_area.mouse_click.connect(_on_timer_click_area_click)
	settings_window.close_requested.connect(settings_window.hide)


func _on_timer_click_area_click() -> void:
	print("bajo")
	meow_player.stop()
	
	if not pomodoro_timer.time_left:
		bengi_animator.play("RESET")
		get_window().always_on_top = false
		pomodoro_timer.start()
		
		var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(timer_sprite, "rotation_degrees", 360, 0.5)
		tween.tween_callback(
			func():
				timer_sprite.rotation_degrees = 0
		)


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
	
	if _current_timer_mode == TimerMode.WORK && ConfigManager.rest_time > 0:
		_current_timer_mode = TimerMode.REST
		pomodoro_timer.wait_time = max(ConfigManager.rest_time * 60, 1)
		activity_label.text = "Przerwa"
		activity_label.modulate = Color.SLATE_BLUE
	
	elif _current_timer_mode == TimerMode.REST && ConfigManager.work_time > 0:
		_current_timer_mode = TimerMode.WORK
		pomodoro_timer.wait_time = max(ConfigManager.work_time * 60, 1)
		activity_label.text = "Praca"
		activity_label.modulate = Color.WHITE
	


func _on_exit_button_pressed() -> void:
	ConfigManager.save_config()
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	settings_window.show()
