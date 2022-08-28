tool
extends VBoxContainer

export (PackedScene) var dep_entry_scene : PackedScene

var module : ModuleDef

onready var prop_module_name := $"%PropModuleNameValue"
onready var prop_module_path := $"%PropModulePathValue"
onready var list_deps := $"%ListDeps"
onready var btn_add_ref := $"%BtnAddNewRef"
onready var btn_toggle_deps := $"%BtnDeps"

signal request_refresh(filepath)

"""
- - - - - - - - - - - - - - - - - |
	Initialization
- - - - - - - - - - - - - - - - - |
"""


func create(m_module : ModuleDef) -> void:
	module = m_module
	
func _ready() -> void:
	_rebuild()

func _rebuild() -> void:
	if not module:
		push_error("Attempted to create an inspector for a null object, type=ModuleDef")
		queue_free()
		return
	prop_module_name.text = module.module_name
	prop_module_path.text = module.root_folder
	for i in range(list_deps.get_child_count()-1):
		var n := list_deps.get_child(0)
		list_deps.remove_child(n)
	for d in module.dependencies:
		_add_dependency_entry(d)
	if list_deps.get_child_count() > 1:
		list_deps.move_child(btn_add_ref, list_deps.get_child_count()-1)
	list_deps.visible = false
	btn_toggle_deps.text = "Dependencies [%s]" % str(module.dependencies.size())

func _add_dependency_entry(dep_path : String) -> void:
	var entry = dep_entry_scene.instance()
	entry.create(dep_path)
	list_deps.add_child(entry)
	entry.connect("remove_entry", self, "_remove_dependency", [entry])

"""
- - - - - - - - - - - - - - - - - |
	Button Signals
- - - - - - - - - - - - - - - - - |
"""

func _on_BtnRefresh_pressed() -> void:
	print("Refresh")
	module.refresh()
	save_resource()

func _on_BtnViewGraph_pressed() -> void:
	print("View Graph")

func _on_BtnDeps_pressed() -> void:
	list_deps.visible = not list_deps.visible

func _on_BtnAddNewRef_pressed() -> void:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.mode = FileDialog.MODE_OPEN_FILE
	dialog.filters = PoolStringArray(["*.csproj ; C# Project Files"])
	get_tree().root.add_child(dialog)
	dialog.connect("file_selected", self, "_add_dependency_internal")
	dialog.popup_centered_ratio()

func _on_BtnOpenFolder_pressed() -> void:
	var file := File.new()
	file.open(module.resource_path, File.READ)
	var path := file.get_path_absolute()
	path = path.replace(path.get_file(), "")
	var uri := str("file://", path)
	OS.shell_open(uri)

func _on_BtnViewCsproj_pressed() -> void:
	print("View csproj file as text")
	var res_path := module.root_folder + "/" + module.module_name
	var file := File.new()
	file.open(res_path, File.READ)
	OS.shell_open("file://" + file.get_path_absolute())

"""
- - - - - - - - - - - - - - - - - |
	Other Signals
- - - - - - - - - - - - - - - - - |
"""

func _add_dependency_internal(path : String) -> void:
	var relative := PathHelper.relative_path(module.resource_path, path)
	relative = relative.replace("/", "\\")
	print("Add dep:\n\tPath : ", path, "\n\tRelative : ", relative)
	if relative in module.dependencies:
		push_warning("Dependency [%s] already exists in [%s]" % [relative, module.module_name])
		return
	if relative.get_file() == module.module_name:
		push_warning("Module [%s] cannot be a dependant of itself" % module.module_name)
		return
	var folder := path.get_base_dir()
	if folder == "res://":
		push_warning("Module [%s] cannot depend on the project solution" % module.module_name)
		return
	# checks have passed, this reference should be generated:
	var project_path := OS.get_executable_path().get_base_dir()
	var abs_path := project_path + path.replace("res://", "/")
	print("Abs Path:", abs_path)
	

func _remove_dependency(path : String, dep_node : Control) -> void:
	# change module reference
	var index := module.dependencies.find(path)
	if index >= 0:
		module.dependencies.remove(index)

	# change UI
	list_deps.remove_child(dep_node)
	dep_node.queue_free()
	
	# Write changes to resource file
	save_resource()

	# Write changes to csproj file
	push_error("Writing changes to csproj not implemented!")

func save_resource() -> void:
	ResourceSaver.save(module.resource_path, module)
	emit_signal("request_refresh", module.resource_path)
	_rebuild()
