extends Node


func _ready() -> void:
	var output := []
	OS.execute("pwd", [], true, output)
	print(output)
