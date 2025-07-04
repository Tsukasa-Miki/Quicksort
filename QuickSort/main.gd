extends Node2D
var test = preload("res://node_2d.tscn")
var counter = 0
func _on_button_pressed() -> void:
	get_child(3).queue_free()
	add_child(test.instantiate())
func _process(delta: float) -> void:
	$Button/Label2.text=var_to_str(int($HSlider.value))
	$Button/Label3.text="Operações:\n"+var_to_str(counter)
	$Label.text="FPS:"+var_to_str(Engine.get_frames_per_second())
