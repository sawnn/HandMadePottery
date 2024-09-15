extends Node

var is_pottery_active = true

var levels = [
	"res://scenes/main_menu.tscn",
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn"
]
@onready var score_text: Label = $ScoreUi/ScoreText

var score = 0

var current_level = 0
func _ready() -> void:
	start_pottery()
	

func stop_pottery():
	print("Stopping pottery...")
	is_pottery_active = false
	#show_score_ui()

func start_pottery():
	print("Starting pottery...")
	is_pottery_active = true
	
func load_level(level_index: int):
	if level_index < 0 or level_index >= levels.size():
		print("Niveau invalide")
		return

	var level_path = levels[level_index]
	var level_scene = load(level_path)  # Charger la scène

	if level_scene:
		# Utilise 'change_scene_to_packed()' pour changer directement de scène
		get_tree().change_scene_to_packed(level_scene)
		start_pottery()
		print("Niveau chargé :", level_path)
	else:
		print("Erreur lors du chargement du niveau :", level_path)

func main_menu_level():
	load_level(0)
	current_level = 0

func next_level():
	current_level += 1
	if current_level >= levels.size():
		current_level = 1
		load_level(1)
	else:
		load_level(current_level)


func restart_level():
	load_level(current_level)
