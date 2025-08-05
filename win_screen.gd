extends CanvasLayer

@onready var score_label = $VBoxContainer/ScoreLabel

func _ready():
	# Başlangıçta gizli
	visible = false

func show_win_screen(score: int = 0):
	# Update score
	score_label.text = "Score: " + str(score)
	
	# Show win screen
	visible = true
	
	# Pause game
	get_tree().paused = true

func _on_restart_button_pressed():
	print("Restart button pressed!")  # Debug mesajı
	
	# Resume game
	get_tree().paused = false
	print("Game unpaused")  # Debug mesajı
	
	# Reload scene
	get_tree().reload_current_scene()
	print("Scene reloading...")  # Debug mesajı 
