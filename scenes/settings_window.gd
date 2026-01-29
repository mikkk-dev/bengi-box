extends Window


var _work_time_label_tween: Tween
var _rest_time_label_tween: Tween

func _ready() -> void:
	ConfigManager.config_ready.connect(_update_settings_values)
	ConfigManager.config_updated.connect(_update_settings_values)
	visibility_changed.connect(_update_settings_values)
	%WorkTimeLabel.pivot_offset = Vector2(36, 20)
	%RestTimeLabel.pivot_offset = Vector2(36, 20)


func _tween_time_label(label: Label, tween: Tween, dir: int) -> void:
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween() \
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween.tween_property(label, "scale", label.scale  * 1.1, 0.3)
	tween.tween_property(label, "rotation_degrees", label.rotation_degrees  + 15 * dir, 0.3)
	tween.set_parallel(false)
	tween.tween_interval(1)
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2.ONE, 0.3)
	tween.tween_property(label, "rotation_degrees", 0, 0.3)


func _update_settings_values() -> void:
	%WorkTimeLabel.text = str(ConfigManager.work_time)
	%RestTimeLabel.text = str(ConfigManager.rest_time)
	%BorderlessIcon.visible = ConfigManager.borderless


func _on_work_time_minus_btn_pressed() -> void:
	ConfigManager.work_time -= 1
	_tween_time_label(%WorkTimeLabel, _work_time_label_tween, -1)


func _on_work_time_plus_btn_pressed() -> void:
	ConfigManager.work_time += 1
	_tween_time_label(%WorkTimeLabel, _work_time_label_tween, 1)


func _on_rest_time_minus_btn_pressed() -> void:
	ConfigManager.rest_time -= 1
	_tween_time_label(%RestTimeLabel, _rest_time_label_tween, -1)


func _on_rest_time_plus_btn_pressed() -> void:
	ConfigManager.rest_time += 1
	_tween_time_label(%RestTimeLabel, _rest_time_label_tween, 1)
