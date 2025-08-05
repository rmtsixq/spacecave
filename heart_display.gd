extends Node2D

@onready var player = get_parent()
var hearts = []

func _ready():
	# 3 kalp oluştur (basit kırmızı daireler)
	for i in range(3):
		var heart = create_heart_sprite()
		heart.position = Vector2(i * 30, -50)  # Kalpleri yan yana diz
		add_child(heart)
		hearts.append(heart)

func create_heart_sprite():
	var heart = Node2D.new()
	
	# Kalp şekli için basit kırmızı daire
	var circle = ColorRect.new()
	circle.size = Vector2(20, 20)
	circle.color = Color.RED
	circle.position = Vector2(-10, -10)  # Merkeze hizala
	heart.add_child(circle)
	
	return heart

func update_hearts():
	var current_health = player.current_health
	
	# Kalpleri güncelle
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].visible = true  # Kalp görünür
		else:
			hearts[i].visible = false  # Kalp gizli

func _process(delta):
	update_hearts() 
