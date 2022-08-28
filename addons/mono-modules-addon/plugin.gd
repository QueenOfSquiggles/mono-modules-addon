tool
extends EditorPlugin

var module_def_inspector : EditorInspectorPlugin

func _enter_tree() -> void:
	module_def_inspector = preload("res://addons/mono-modules-addon/ModuleDefInspector.gd").new()
	add_inspector_plugin(module_def_inspector)

func _exit_tree() -> void:
	remove_inspector_plugin(module_def_inspector)
