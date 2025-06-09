#game.gd

extends Node2D

@onready var fade_rect = $FadeRect  # a ColorRect node for fade effect
@onready var end_screen = $EndScreen  # a Control node containing text + button
@onready var return_button = $EndScreen/VBoxContainer/ReturnButton
@onready var coldheart = $Coldheart  # or use `get_node()` if it's instanced

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coldheart.coldheart_died.connect(_on_coldheart_coldheart_died)
	return_button.pressed.connect(_on_return_button_pressed)
	
func _on_coldheart_coldheart_died() -> void:
	print("coldheart_died signal received")
	#Fade to black over 1.5 seconds
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.5)
	tween.finished.connect(_show_end_screen)
	end_screen.visible = true
	
func _show_end_screen():
	end_screen.visible = true
	
func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")
