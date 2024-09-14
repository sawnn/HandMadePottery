extends MeshInstance3D

@onready var mesh_instance: MeshInstance3D = $"."
@onready var cerceau: MeshInstance3D = $"../Cerceau"
var camera_3d
var rayOrigin = Vector3()
var rayEnd = Vector3()

func _ready():
	camera_3d = Globals.camera
	print(camera_3d)

func hollow_old(min: float, max: float, depth: float):
	var origin = mesh_instance.transform.origin
	
	var cylinder_mesh = mesh_instance.mesh
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(cylinder_mesh, 0)
	
	var array_mesh = surface_tool.commit()
	var mesh_data = array_mesh.surface_get_arrays(0)
	var vertices = mesh_data[Mesh.ARRAY_VERTEX]
	
	var result = PackedVector3Array()
	for vertex in vertices:
		if  min < vertex.y and vertex.y < max:
			var new_x = vertex.x + (origin.x - vertex.x) * depth
			var new_z = vertex.z + (origin.z - vertex.z) * depth
			result.append(Vector3(new_x, vertex.y, new_z))
		else:
			result.append(Vector3(vertex.x, vertex.y, vertex.z))
	
	var new_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = result
	arrays[Mesh.ARRAY_NORMAL] = mesh_data[Mesh.ARRAY_NORMAL]
	arrays[Mesh.ARRAY_TEX_UV] = mesh_data[Mesh.ARRAY_TEX_UV]
	arrays[Mesh.ARRAY_INDEX] = mesh_data[Mesh.ARRAY_INDEX]
	
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	mesh_instance.mesh = new_mesh
	

func hollow(depth: float, mouse_position: Vector3):
	var origin = mesh_instance.transform.origin
	
	var cylinder_mesh = mesh_instance.mesh
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(cylinder_mesh, 0)
	
	var array_mesh = surface_tool.commit()
	var mesh_data = array_mesh.surface_get_arrays(0)
	var vertices = mesh_data[Mesh.ARRAY_VERTEX]
	
	var result = PackedVector3Array()
	for vertex in vertices:
		var v = vertex.rotated(Vector3(0, 1, 0), self.global_rotation.y)
		#if abs(v.y - mouse_position.y) < 0.1:
		if mouse_position.distance_to(v) < 0.4:
			var new_x = vertex.x + (origin.x - vertex.x) * depth
			var new_z = vertex.z + (origin.z - vertex.z) * depth
			result.append(Vector3(new_x, vertex.y, new_z))
		else:
			result.append(Vector3(vertex.x, vertex.y, vertex.z))
	
	var new_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = result
	arrays[Mesh.ARRAY_NORMAL] = mesh_data[Mesh.ARRAY_NORMAL]
	arrays[Mesh.ARRAY_TEX_UV] = mesh_data[Mesh.ARRAY_TEX_UV]
	arrays[Mesh.ARRAY_INDEX] = mesh_data[Mesh.ARRAY_INDEX]
	
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	mesh_instance.mesh = new_mesh
	
func _physics_process(delta: float) -> void:
	self.global_rotate(Vector3(0, 1, 0), 5 * delta)
	if Input.is_action_pressed("click"):
		var mouse_position = get_mouse_position()
		if mouse_position != Vector3.ZERO:
			hollow(0.8 * delta,mouse_position)


func get_mouse_position() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	
	var mouse_position = get_viewport().get_mouse_position()
	
	rayOrigin = camera_3d.project_ray_origin(mouse_position)
	rayEnd = rayOrigin + camera_3d.project_ray_normal(mouse_position) * 200
	
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	var intersection = space_state.intersect_ray(query)
	
	if not intersection.is_empty():
		return intersection.position
	return Vector3.ZERO
	
	
