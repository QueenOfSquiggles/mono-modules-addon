extends EditorInspectorPlugin

var inspector_control := preload("res://addons/mono-modules-addon/scenes/ModuleInspector.tscn")

signal request_refresh(path)

func can_handle(object: Object) -> bool:
	return object is ModuleDef

func parse_begin(object: Object) -> void:
	var ctrl := inspector_control.instance()
	add_custom_control(ctrl)
	ctrl.create(object as ModuleDef)
	ctrl.connect("request_refresh", self, "_refresh_file")

func _refresh_file(path : String) -> void:
	emit_signal("request_refresh", path)

func parse_property(object: Object, type: int, path: String, hint: int, hint_text: String, usage: int) -> bool:
	if path == "description":
		return false
	return true
