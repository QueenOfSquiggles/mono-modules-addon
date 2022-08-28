extends Node


func _ready() -> void:
	var data = XMLHelper.read_xml("res://modules/use_dependencies/use_dependencies.csproj")
	data = XMLHelper.join_path(data, "Project/ItemGroup/ProjectReference")
	var includes :Array = XMLHelper.join_attributes(data)["Include"]
	
	print("Includes:\n", JSON.print(includes, "\t", true))
