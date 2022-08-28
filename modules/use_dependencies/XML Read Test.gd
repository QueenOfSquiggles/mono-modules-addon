extends Node


func _ready() -> void:
	var data = XMLHelper.read_xml("res://modules/use_dependencies/use_dependencies.csproj")
	if data.has("Project/ItemGroup/ProjectReference"):
		# module has dependencies
		var includes = data["Project/ItemGroup/ProjectReference"]["attribs"]
		pass
