extends Button


var _tween: Tween


func _ready() -> void:
	pivot_offset_ratio = Vector2(0.5, 0.5)
	
	pressed.connect(
		func():
			if _tween:
				_tween.kill()
			
			_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
			_tween.tween_property(self, "scale", Vector2.ONE * 0.9, 0.1)
			_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	)
