#end_screen.gd

extends Control

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")
