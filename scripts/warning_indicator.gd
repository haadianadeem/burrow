#warning_indicator.gd 

extends Control

@onready var icon: TextureRect = $TextureRect

func _ready(): 
	print("WarningIndicator ready. icon is: ", icon)
	if icon == null:
		print("ERROR: icon is null! Check if 'TextureRect' exists and is named correctly.")
	icon.visible = false
	visible = false

func show_warning(side: String, duration: float):
	# Make visible
	visible = true
	icon.visible = true
	icon.modulate = Color(1, 0, 0, 1)

	# Position on left or right side of screen
	var screen_size = get_viewport_rect().size
	var y_pos = screen_size.y / 2 - icon.size.y / 2

	if side == "left":
		icon.position = Vector2(20, y_pos)
	elif side == "right":
		icon.position = Vector2(screen_size.x - icon.size.x - 20, y_pos)

	# Flash and then hide
	var flash_tween = create_tween()
	flash_tween.tween_property(icon, "modulate:a", 0.0, 0.3).set_loops(4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).chain().tween_callback(func():
		icon.visible = false
		visible = false
	)
