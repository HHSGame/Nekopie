extends Control

func _ready() -> void:
	# Print layout after everything is set up
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	var log_file = "user://layout_debug.txt"
	var f = FileAccess.open(log_file, FileAccess.WRITE)
	if not f:
		push_error("DebugLayout: Could not open log file")
		return
	
	var root = get_parent()
	f.store_line("=== NODE LAYOUT DEBUG ===")
	_print_node(root, f, 0)
	f.store_line("=== END DEBUG ===")
	f.close()
	print("DebugLayout: Wrote layout to ", log_file)

func _print_node(node: Node, f: FileAccess, depth: int) -> void:
	var indent = ""
	for i in depth:
		indent += "  "
	
	if node is Control:
		var pos = node.position
		var size = node.size
		var min_size = node.custom_minimum_size
		var z = node.z_index
		var clip = node.clip_contents
		var vis = node.visible
		f.store_line(indent + node.name + \
			" pos=" + str(pos.x) + "," + str(pos.y) + \
			" size=" + str(size.x) + "," + str(size.y) + \
			" min=" + str(min_size.x) + "," + str(min_size.y) + \
			" z=" + str(z) + " clip=" + str(clip) + " vis=" + str(vis))
	else:
		f.store_line(indent + node.name + " [" + node.get_class() + "]")
	
	for child in node.get_children():
		_print_node(child, f, depth + 1)