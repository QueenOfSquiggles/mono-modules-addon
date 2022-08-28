tool
extends Resource
class_name ModuleDef, "res://addons/mono-modules-addon/icons/widgets_FILL1_wght700_GRAD-25_opsz20.svg"

export var module_name : String = "tbd"
export var root_folder : String = "tbd"
export var dependencies := ["tbd", "tbd2"]

export (String, MULTILINE) var description := ""

func _init() -> void:
	# called on creation
	refresh()

func refresh() -> void:
	# called manually to refresh data
	root_folder = _get_folder()
	if root_folder.begins_with("/"):
		push_warning("Weird edge case hit! root folder starts with '/', not 'res://'")
		return
	module_name = _find_csproj()
	dependencies = _get_dependencies(root_folder + "/" + module_name)
	resource_name = module_name
	ResourceSaver.save(resource_path, self)
	print("ModuleDef done refreshing")

func _get_folder() -> String:
	return resource_path.get_base_dir()

func _find_csproj() -> String:
	var dir := Directory.new()
	dir.open(root_folder)
	dir.list_dir_begin(true, true)
	var filepath :String= dir.get_next()
	while not filepath.empty():
		if filepath.to_lower().ends_with(".csproj"):
			break
		filepath = dir.get_next()
	dir.list_dir_end()
	if not filepath.is_valid_filename():
		push_error("Failed to find a csproj in the same folder as this ModuleDef. This is a problem?")
		return ""
	return filepath.get_file()

func _get_dependencies(path : String) -> Array:
	print("Loading deps for ", path)
	var data = XMLHelper.read_xml(path)
	data = XMLHelper.join_path(data, "Project/ItemGroup/ProjectReference")
	var data_attribs := XMLHelper.join_attributes(data)
	if not data_attribs.has("Include"):
		# no references. Totally OK
		return []
	return data_attribs["Include"]
