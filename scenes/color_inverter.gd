extends Node


func _ready() -> void:
	var parent = get_parent()
	
	if parent is Button:
		parent.pressed.connect(
			func():
				parent.material.set("shader_parameter/is_clicked", true)
				await get_tree().create_timer(0.2).timeout
				parent.material.set("shader_parameter/is_clicked", false)
		)
