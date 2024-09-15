extends CanvasLayer
@onready var timer: Timer = $"../Timer"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	GameManager.main_menu_level()
	


func _on_resume_button_pressed() -> void:
	timer.paused = false
	self.visible = false
