extends Control

func _ready():
	visible = false
	call_deferred("_setup_buttons")



func _setup_buttons():
	var restart_button = $RestartButton
	var exit_button = $ExitButton
	
	if restart_button != null:
		restart_button.pressed.connect(_on_restart_button_pressed)
		print("RestartButton connected successfully")
	else:
		print("ERROR: RestartButton not found!")
		
	if exit_button != null:
		exit_button.pressed.connect(_on_exit_button_pressed)
		print("ExitButton connected successfully")
	else:
		print("ERROR: ExitButton not found!")

func show_screen():
	visible = true
	get_tree().paused = true

func _on_restart_button_pressed():
	print("Restart clicked")
	get_tree().paused = false

	var current_scene = get_tree().current_scene
	var scene_path = current_scene.filename

	if scene_path != "":
		var new_scene = load(scene_path).instantiate()
		get_tree().root.remove_child(current_scene)
		current_scene.queue_free()
		get_tree().root.add_child(new_scene)
		get_tree().current_scene = new_scene
	else:
		print("Current scene has no path!")

func _on_exit_button_pressed():
	get_tree().quit()
