extends EditorProperty

func _init() -> void:
	var btn := Button.new()
	btn.text = "Hello there!"
	add_child(btn)
