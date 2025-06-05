#intro_screen_2.gd

extends Control


func _on_continue_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/intro_screen_3.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/intro_screen.tscn")
