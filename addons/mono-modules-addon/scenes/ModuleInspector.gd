tool
extends VBoxContainer
"""
A highly customized inspector for the ModuleDef resource.
Lots of functionality is stored here
"""


# this is what generates the default project data. Change this to change the defaults
# Will not alter existing csproj files, only new ones created after the change
const DEFAULT_CSPROJ := "<Project Sdk=\"Godot.NET.Sdk/3.3.0\">\n" + \
	"\t<PropertyGroup>\n" + \
	"\t\t<TargetFramework>net472</TargetFramework>\n" + \
	"\t</PropertyGroup>\n" + \
	"</Project>\n"

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
	module.refresh()
	if module.module_name == "":
		# no csproj file
		var dialog := ConfirmationDialog.new()
		dialog.dialog_text = "No *.csproj file found in the directory '"+module.root_folder+"', would you like to create it now?"
		get_tree().root.add_child(dialog)
		dialog.connect("confirmed", self, "_try_create_csproj")
		dialog.popup_centered()

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
	if not _check_project_solution_contains_module():
		var btnAddToSolution := Button.new()
		add_child(btnAddToSolution)
		move_child(btnAddToSolution, 0)
		btnAddToSolution.text = "Add to Project Solution (dotnet SDK required)"
		btnAddToSolution.connect("pressed", self, "_run_cmd_add_to_sln")

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
	_write_dependency_to_csproj(module.get_csproj(), relative)
	

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
	_remove_dependency_from_csproj(module.get_csproj(), path)

func _try_create_csproj() -> void:
	var file := File.new()
	var path := module.resource_path.replace(".tres", ".csproj")
	var err := file.open(path, File.WRITE)
	if err != OK:
		push_error("failed to generate file: %s" % path)
		return
	file.store_string(DEFAULT_CSPROJ)
	file.close()
	call_deferred("_rebuild")

func save_resource() -> void:
	ResourceSaver.save(module.resource_path, module)
	emit_signal("request_refresh", module.resource_path)
	_rebuild()

func _write_dependency_to_csproj(proj_path : String, dep_relative : String) -> void:
	var file := File.new()
	if not file.open(proj_path, File.READ) == OK:
		push_error("failed to open file : " + proj_path)
		return
	var former_proj :String = file.get_as_text(true)
	file.close()
	var new_proj := former_proj
	if module.dependencies.empty():
		# create new ItemGroup tags
		var first_open := former_proj.find(">") + 1
		new_proj = former_proj.insert(first_open, \
		"\n\n\t<ItemGroup>\n" + \
		"\t\t<ProjectReference Include=\""+dep_relative+"\" />\n" + \
		"\t</ItemGroup>\n")
	else:
		# ItemGroup tags should exist, find and insert a new set
		var num_item_groups := former_proj.findn("ItemGroup") / 2
		var first_open := former_proj.find("ItemGroup>") + 1
		var next_open := former_proj.find("ItemGroup>", first_open)
		var existing_proj_ref := former_proj.find("<ProjectReference", first_open)
		var safety_count := 0
		while existing_proj_ref > next_open:
			first_open = next_open
			next_open =  former_proj.find("ItemGroup>", first_open)
			existing_proj_ref = former_proj.find("<ProjectReference", first_open)
			safety_count += 1
			if safety_count > num_item_groups:
				push_warning("Failed to find existing <ProjectReference> tag in a module with existing dependencies! Check the file, something weird is going on!!")
				return
		new_proj = former_proj.insert(existing_proj_ref-1, \
		"<ProjectReference Include=\""+dep_relative+"\" />\n")
	_on_csproj_edited(proj_path, new_proj)

func _remove_dependency_from_csproj(proj_path : String, dep_relative : String) -> void:
	print("removing dep [%s] from module [%s]" % [dep_relative, module.module_name])
	var file := File.new()
	if not file.open(proj_path, File.READ) == OK:
		push_error("Failed to open file: " + proj_path)
	var former_proj := file.get_as_text(false)
	file.close()
	
	var lines := former_proj.split("\n") as Array
	var index := 0
	while index < lines.size():
		if dep_relative in lines[index]:
			break;
		index += 1
	if index == lines.size():
		push_warning("Failed to find dependency '%s' in module %s" % [dep_relative, proj_path])
	lines.remove(index)
	var new_proj := ""
	for i in range(lines.size()-1):
		new_proj += lines[i] + "\n"
	new_proj += lines.back()
	_on_csproj_edited(proj_path, new_proj)
	
func _on_csproj_edited(proj_path : String, new_proj : String) -> void:
	var dir := Directory.new()
	dir.remove(proj_path)
	var file := File.new()
	file.open(proj_path, File.WRITE)
	file.store_string(new_proj)
	file.close()
	call_deferred("_rebuild")

func _check_project_solution_contains_module() -> bool:
	var dir := Directory.new()
	var sln_path := ""
	dir.open("res://")
	dir.list_dir_begin(true, true)
	var cur_dir_file :String= dir.get_next()
	while not cur_dir_file.ends_with(".sln") and not cur_dir_file.empty():
		cur_dir_file = dir.get_next()
	dir.list_dir_end()

	if not cur_dir_file.is_valid_filename():
		push_error("Failed to find .sln solution file in project root folder")
		return true # true because nothing can be done if the SLN doesn't exist
	var file := File.new()
	if file.open(cur_dir_file, File.READ) == OK:
		var sln_text := file.get_as_text(true)
		var csproj_path := module.get_csproj()
		csproj_path = csproj_path.replace("res://", "").replace("/", "\\")
		print("Expected csproj path in sln: ", csproj_path)
		return csproj_path in sln_text
	return false
	
func _run_cmd_add_to_sln() -> void:
	var output := []
	var friendly_path := module.get_csproj().replace("res://", "")
	OS.execute("dotnet", ["sln", "add", friendly_path], true, output)
	
	yield(get_tree().create_timer(0.1), "timeout")
	var double_check := _check_project_solution_contains_module()
	var res := "Success" if double_check else "Failed?"
	var out_text := "Command executed in shell. Results: [%s]\n\n" % res
	for i in range(output.size()-1):
		out_text += output[i] + "\n"
	out_text += output.back()
	
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = out_text
	get_tree().root.add_child(dialog)
	dialog.popup_centered()



