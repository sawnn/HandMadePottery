extends Timer

@onready var timer_label: Label = $"../CanvasLayer/TimerLabel"
@onready var score_ui: CanvasLayer = $"../ScoreUi"
@onready var pause_ui: CanvasLayer = $"../PauseUi"
@onready var score_text: Label = $"../ScoreUi/ScoreText"
@onready var poterie: MeshInstance3D = $"../Poterie/RigidBody3D/MeshInstance3D"
@onready var modele: MeshInstance3D = $"../MeshInstance3D"

func _ready() -> void:
	print(poterie)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if (pause_ui):
			pause_ui.visible = not pause_ui.visible
			if pause_ui.visible:
				self.paused = true
				GameManager.stop_pottery()
			else:
				self.paused = false
				GameManager.start_pottery()
	timer_label.text = "%d:%02d" % [floor(self.time_left / 60), int(self.time_left) % 60]


func compute_score() -> float:
	var origin_bak = modele.transform.origin
	modele.transform.origin = Vector3.ZERO
	var v1 = get_vertices(poterie.mesh)
	var v2 = get_vertices(modele.mesh)
	
	var distance = 0.0
	var len = min(v1.size(), v2.size())
	var max = 0
	for i in range(len):
		var a = v1[i]
		var b = v2[i]
		var dist = Vector3(a.x, 0, a.z).distance_to(Vector3(b.x, 0, b.z))
		if max < dist:
			max = dist
		distance += dist
	
	var average = distance / len
	modele.transform.origin = origin_bak
	
	return round((1 - average) * 100)
	if average > 0.4:
		return 0
	elif 0.2 < average and average <= 0.4:
		var score = (0.4 - average) / (0.4 - 0.2) * 75
		return round(score)
	elif 0.05 < average and average <= 0.2:
		var score = 76 + (0.2 - average) / (0.2 - 0.05) * (98 - 76)
		return round(score)
	else:
		return 100
	

func get_vertices(mesh: Mesh) -> PackedVector3Array:
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(mesh, 0)
	
	var array_mesh = surface_tool.commit()
	var mesh_data = array_mesh.surface_get_arrays(0)
	return mesh_data[Mesh.ARRAY_VERTEX]

func _on_timeout() -> void:
	print("timer stp")
	if (score_ui):
		score_ui.visible = true
		score_text.text = "Score: " + str(compute_score())
	GameManager.stop_pottery()
