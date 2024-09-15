extends Timer

@onready var timer_label: Label = $"../CanvasLayer/TimerLabel"
@onready var score_ui: CanvasLayer = $"../ScoreUi"
@onready var pause_ui: CanvasLayer = $"../PauseUi"


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



func _on_timeout() -> void:
	print("timer stp")
	if (score_ui):
		score_ui.visible = true
	GameManager.stop_pottery()
