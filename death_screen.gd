extends CanvasLayer

@onready var score_label = $VBoxContainer/ScoreLabel

func _ready():
	# Başlangıçta gizli
	visible = false

func show_death_screen(score: int = 0):
	# Skoru güncelle
	score_label.text = "Skor: " + str(score)
	
	# Ölüm ekranını göster
	visible = true
	
	# Oyunu duraklat
	get_tree().paused = true

func _on_restart_button_pressed():
	# Oyunu devam ettir
	get_tree().paused = false
	
	# Sahneyi yeniden yükle
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	# Oyunu kapat
	get_tree().quit() 