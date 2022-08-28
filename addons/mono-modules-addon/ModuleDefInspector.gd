extends EditorInspectorPlugin

var prop_string_label := preload("res://addons/mono-modules-addon/property_editors/PropStringLabel.gd")
var prop_dependencies := preload("res://addons/mono-modules-addon/property_editors/PropDependenciesEditor.gd")

func can_handle(object: Object) -> bool:
	return object is ModuleDef

func parse_begin(object: Object) -> void:
	var btn := Button.new()
	btn.text = "Header Button"
	add_custom_control(btn)

func parse_property(object: Object, type: int, path: String, hint: int, hint_text: String, usage: int) -> bool:
	var module := object as ModuleDef
	match path:
		# match named exceptions
		"description":
			return false
		"dependencies":
			add_property_editor(path, prop_dependencies.new())
			return true
		"module_name":
			add_property_editor(path, prop_string_label.new("The name of this module"))
			return true
		"root_folder":
			add_property_editor(path, prop_string_label.new("The root folder of this module and the csproj file referenced internally"))
			return true
	return true
