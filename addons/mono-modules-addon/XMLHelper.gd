tool
extends Node
class_name XMLHelper

"""
A general purpose XML Parser that converts from and to Dictionary types

XML:
	<A>
		<B/>
		<C alt="n">data</C>
	</A>
Dictionary (JSON representation):
	{
		"A": {
			children: {
				"B": {},
				"C": {
					"alt": "n",
					"contents": "data"
				}
			}
		}
	}
"""

class XMLNode:
	var name := "" # node name
	var text := "" # text (NODE_TEXT)
	var attribs := {} # attributes key:value
	
static func read_xml(path : String) -> Dictionary:
	var parser := XMLParser.new()
	if parser.open(path) != OK:
		return {}

	var data := {}
	var node_stack := []
	
	parser.read()
	var cur_node_type := parser.get_node_type()
	
	while cur_node_type != XMLParser.NODE_NONE:
		cur_node_type = parser.get_node_type()
		
		match cur_node_type:
			XMLParser.NODE_TEXT:
				var node_data = parser.get_node_data()
				if not node_data.empty() and not node_data.begins_with("\n"):
					data[_stack_path(node_stack)]["text"] = node_data

			XMLParser.NODE_ELEMENT:
				var node = parser.get_node_name()
				node_stack.push_back(node)
				data[_stack_path(node_stack)] = {
					"text" : "",
					"attribs" : {}
				}
				
				var attrib_count = parser.get_attribute_count()
				for i in range(attrib_count):
					var key = parser.get_attribute_name(i)
					var value = parser.get_attribute_value(i)
					data[_stack_path(node_stack)]["attribs"][key] = value # icky access method!

			XMLParser.NODE_ELEMENT_END:
				var node = parser.get_node_name()
				node_stack.pop_back()
			
			_:
				push_warning("Unhandled node: #%s" % cur_node_type)
		
		var err = parser.read()
		if err != OK: # includes EOF
			break

	print(JSON.print(data, "\t", true))
	return data

static func _stack_path(stack : Array) -> String:
	var path := ""
	if stack.empty():
		return ""
		
	for i in range(stack.size()-1):
		path += stack[i] + "/"

	path += stack[stack.size() - 1]
	return path

static func write_xml(path : String, xml_data : Dictionary) -> void:
	pass
