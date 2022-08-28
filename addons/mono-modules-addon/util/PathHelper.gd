tool
extends Node
class_name PathHelper

"""
I have no clue why finding the relative path isn't built-in? I suppose all internal Godot elements prefer absolute paths. But at least provide the option???
"""

static func relative_path(file_from : String, file_to : String) -> String:
	var stack_a :Array= file_from.split("/")
	var stack_b :Array= file_to.split("/")
	var a := ""
	var b := ""
	while a == b:
		a = stack_a.pop_front()
		b = stack_b.pop_front()
	stack_a.push_front(a)
	stack_b.push_front(b)
	# similar structure cleared

	# add ../ for each element in stack_a, suffix is stack b
	var path := ""
	for i in range(stack_a.size()-1):
		path += "../"
	for i in range(stack_b.size()-1):
		path += stack_b[i] + "/"
	path += stack_b.back()
	return path
