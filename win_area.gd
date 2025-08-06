extends Area2D

func _ready():

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		get_node("/root/main/WinScreen").show_screen()
   
