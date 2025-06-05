extends Control


func _on_start_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/game.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")
