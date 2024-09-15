extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if not GameManager.is_pottery_active:
		return
	self.global_rotate(Vector3(0, 1, 0), 5 * delta)
