extends Control

func _ready():
	# Wait for scene to fully load
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("user://debug_screenshot.png")
	print("DEBUG: Screenshot saved to user://debug_screenshot.png")
	
	# Also print all node sizes for debugging
	print("=== NODE HIERARCHY ===")
	print_node_tree(get_tree().current_scene, 0)

func print_node_tree(node, depth):
	var indent = "  ".repeat(depth)
	if node is Control:
		print(indent + node.name + " pos=" + str(node.position) + " size=" + str(node.size) + " min=" + str(node.custom_minimum_size))
	for child in node.get_children():
		print_node_tree(child, depth + 1)
