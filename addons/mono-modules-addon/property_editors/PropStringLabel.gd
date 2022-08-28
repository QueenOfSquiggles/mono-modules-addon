extends EditorProperty
"""
Inspector Property that displays strings as a key/value pair
"""

var tooltip :String = ""

func _init(m_tooltip : String = "") -> void:
	read_only = true
	tooltip = m_tooltip
	if get_edited_object() == null:
		var lbl_err := Label.new()
		lbl_err.text = "ERR: Object Found Null!"
		add_child(lbl_err)
		draw_red = true
		return
	var hbox := HBoxContainer.new()
	var key := get_edited_property()
	var value := get_edited_object().get_indexed(key) as String
	var lbl_key := Label.new()
	var lbl_value := Label.new()
	lbl_key.text = key
	lbl_value.text = value
	hbox.add_child(lbl_key)
	hbox.add_child(lbl_value)
	add_child(hbox)
	print("Adding string label inspector editor")

func get_tooltip_text() -> String:
	return tooltip
