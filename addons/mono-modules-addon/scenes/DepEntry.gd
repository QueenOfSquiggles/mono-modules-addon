tool
extends HBoxContainer

signal remove_entry(path)

func create(path : String) -> void:
	$LblPath.text = path
	($LblPath as Label).hint_tooltip = path
	var name = path.get_file()
	if not name.empty():
		var index = name.find(".")
		name = name.substr(0, index)
	$LblName.text = name


func _on_Button_pressed() -> void:
	emit_signal("remove_entry", $LblPath.text)
