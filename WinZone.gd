extends Area2D

var win_screen_scene = preload("res://win_screen.tscn")
var win_screen_instance = null

func _ready():
	# Body entered sinyalini bağla
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Eğer giren body player ise
	if body.has_method("get_score"):  # Player kontrolü
		print("Oyuncu WinZone'a girdi! Oyun kazanıldı!")
		
		# Player'dan skoru al
		var player_score = body.get_score()
		
		# Win screen'i göster - dinamik oluştur
		if not win_screen_instance:
			win_screen_instance = win_screen_scene.instantiate()
			get_tree().root.add_child(win_screen_instance)
		
		win_screen_instance.show_win_screen(player_score) 
