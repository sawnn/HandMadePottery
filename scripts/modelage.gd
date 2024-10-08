extends MeshInstance3D

@onready var mesh_instance: MeshInstance3D = $"."
@onready var collision_shape_3d: CollisionShape3D = $"../CollisionShape3D"
@onready var gpu_particles_3d: GPUParticles3D = $"../../GPUParticles3D"
var rng = RandomNumberGenerator.new()

var camera_3d
var rayOrigin = Vector3()
var rayEnd = Vector3()
var listen_mouse_velocity = false

var history: Array = []

func _ready():
	camera_3d = Globals.camera
	print(camera_3d)


func save_mesh_state():
	var mesh = mesh_instance.mesh
	if mesh == null:
		return
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(mesh, 0)

	var array_mesh = surface_tool.commit()
	var mesh_data = array_mesh.surface_get_arrays(0)

	var state = {
		"vertices": mesh_data[Mesh.ARRAY_VERTEX].duplicate(),
		"normals": mesh_data[Mesh.ARRAY_NORMAL].duplicate(),
		"uvs": mesh_data[Mesh.ARRAY_TEX_UV].duplicate(),
		"indices": mesh_data[Mesh.ARRAY_INDEX].duplicate()
	}
	history.append(state)


func undo():
	print(history.size())
	if history.size() == 0:
		print("No more states to undo.")
		return
	print("here")
	var last_state = history.pop_back()
	var new_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = last_state["vertices"]
	arrays[Mesh.ARRAY_NORMAL] = last_state["normals"]
	arrays[Mesh.ARRAY_TEX_UV] = last_state["uvs"]
	arrays[Mesh.ARRAY_INDEX] = last_state["indices"]

	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh_instance.mesh = new_mesh
	collision_shape_3d.shape = new_mesh.create_trimesh_shape()


func hollow(depth: float, mouse_position: Vector3, spread = 0):
	var origin = mesh_instance.transform.origin
	var first_vertex = null
	var last_vertex = null
	var removed = 0
	
	var cylinder_mesh = mesh_instance.mesh
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(cylinder_mesh, 0)
	
	var array_mesh = surface_tool.commit()
	var mesh_data = array_mesh.surface_get_arrays(0)
	var vertices = mesh_data[Mesh.ARRAY_VERTEX]
	
	var result = PackedVector3Array()
	var i = 0
	for vertex in vertices:
		var v = vertex.rotated(Vector3(0, 1, 0), self.global_rotation.y)
		var rand = rng.randf_range(-0.01, 0.01)
		var new_depth = depth + rand

		#if mouse_position.distance_to(v) < 0.4:
		if abs(v.y - mouse_position.y) < 0.25:
			if first_vertex == null:
				first_vertex = i
			last_vertex = i
			var new_x = vertex.x + (origin.x - vertex.x) * new_depth
			var new_z = vertex.z + (origin.z - vertex.z) * new_depth
			removed += depth / 2
			result.append(Vector3(new_x, vertex.y, new_z))
		else:
			result.append(Vector3(vertex.x, vertex.y, vertex.z))
		i += 1
	
	if spread < 0:
		var spread_delta = removed / 800
		for j in range(max(0, first_vertex - 2000), first_vertex):
			result[j].x -= (origin.x - result[j].x) * spread_delta 
			result[j].z -= (origin.z - result[j].z) * spread_delta
	elif spread > 0:
		var spread_delta = removed / 800
		for j in range(last_vertex, min(result.size(), last_vertex + 2000)):
			result[j].x -= (origin.x - result[j].x) * spread_delta
			result[j].z -= (origin.z - result[j].z) * spread_delta
	
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
	if not GameManager.is_pottery_active:
		gpu_particles_3d.emitting = false
		listen_mouse_velocity = false
		collision_shape_3d.shape = mesh_instance.mesh.create_trimesh_shape()
		return
	
	self.global_rotate(Vector3(0, 1, 0), 5 * delta)
	if Input.is_action_just_pressed("click"):
		save_mesh_state()
	if Input.is_action_pressed("click"):
		var spread = 0
		if listen_mouse_velocity:
			var mouse_velocity = Input.get_last_mouse_velocity()
			if mouse_velocity.y > 250:
				spread = 1
			elif mouse_velocity.y < -250:
				spread = -1
		var mouse_position = get_mouse_position()
		if mouse_position != Vector3.ZERO:
			gpu_particles_3d.emitting = true
			gpu_particles_3d.transform.origin = Vector3(mouse_position.x, mouse_position.y, mouse_position.z+0.4)
			hollow(0.6 * delta,mouse_position, spread)
		listen_mouse_velocity = true
	if Input.is_action_just_pressed("undo"):
		undo()
	if Input.is_action_just_released("click"):
		gpu_particles_3d.emitting = false
		listen_mouse_velocity = false
		collision_shape_3d.shape = mesh_instance.mesh.create_trimesh_shape()

func get_mouse_position() -> Vector3:
	if camera_3d == null:
		return Vector3.ZERO
	var space_state = get_world_3d().direct_space_state
	
	var mouse_position = get_viewport().get_mouse_position()
	
	rayOrigin = camera_3d.project_ray_origin(mouse_position)
	rayEnd = rayOrigin + camera_3d.project_ray_normal(mouse_position) * 200
	
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	var intersection = space_state.intersect_ray(query)
	
	if not intersection.is_empty():
		return intersection.position
	return Vector3.ZERO
	

func _on_start_button_pressed() -> void:
	print("okok")
	undo()
	
