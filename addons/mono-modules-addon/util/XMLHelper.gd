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


static func join_path(xml_data : Dictionary, path : String) -> Dictionary:
	var result := {}
	var index := 0
	var m_path := path
	while xml_data.has(m_path):
		var node : Dictionary = xml_data[m_path]
		for key in node.keys():
			if not result.has(key):
				result[key] = []
			(result[key] as Array).append(node[key])

		index += 1
		m_path = path + ("" if index == 0 else str(index).pad_zeros(2))
	
	return result;

static func join_attributes(xml_node : Dictionary, strip_empty_text : bool = true) -> Dictionary:
	if not xml_node.has("attribs"):
		return {}
	var result := {}
	var attrib_data :Array = xml_node["attribs"]
	for attrib in attrib_data:
		var a_dict := attrib as Dictionary
		for key in a_dict.keys():
			if not result.has(key):
				result[key] = []
			result[key].append(a_dict[key])
	return result

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
				if not node_stack.empty() and node_stack.back() == node:
					var suffix := 1 # numerical increments
					while data.has(_stack_path(node_stack)):
						node_stack[node_stack.size()-1] = node + str(suffix).pad_zeros(2)
						# post-fix: node_stack.back is now <node>X where there exist X duplicates at the same path. This prevents overlap in the dictionary
				else:
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
