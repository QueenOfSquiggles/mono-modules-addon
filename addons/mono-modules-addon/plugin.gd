tool
extends EditorPlugin

var module_def_inspector : EditorInspectorPlugin

func _enter_tree() -> void:
	module_def_inspector = preload("res://addons/mono-modules-addon/ModuleDefInspector.gd").new()
	add_inspector_plugin(module_def_inspector)
	module_def_inspector.connect("request_refresh", self, "_refresh_file")

func _refresh_file(path : String) -> void:
	var filesystem := get_editor_interface().get_resource_filesystem()
	if path.empty():
		filesystem.scan() # updates all files
	else:
		filesystem.update_file(path) # updates a single file

func _exit_tree() -> void:
	remove_inspector_plugin(module_def_inspector)
