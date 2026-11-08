extends SceneTree


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var root: Node = packed.instantiate()
	get_root().add_child(root)
	await process_frame
	await process_frame
	var found := 0
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh: Mesh = node.mesh
		if mesh == null:
			continue
		var size: Vector3 = mesh.get_aabb().size
		if size.x > 3.0 and size.y < 0.35:
			var p: Vector3 = node.global_position
			print("THIN %s pos=(%.2f,%.2f,%.2f) size=(%.2f,%.2f,%.2f) parent=%s" % [
				node.name, p.x, p.y, p.z, size.x, size.y, size.z, node.get_parent().name])
			found += 1
	print("THIN_TOTAL=", found)
	quit()
