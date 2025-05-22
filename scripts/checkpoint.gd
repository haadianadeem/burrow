#checkpoint.gd

extends Area2D

signal activated(position: Vector2)

@onready var flag_sprite: AnimatedSprite2D = $FlagSprite

var is_active = false

func _ready():
	flag_sprite.play("idle")
	connect("body_entered", Callable(self, "_on_body_entered"))
	print("Checkpoint ready")

func _on_body_entered(body: Node2D) -> void:
	print("Checkpoint: Something entered:", body)
	if body.is_in_group("player") and not is_active:
		print("Checkpoint activated at: ", global_position)
		is_active = true
		flag_sprite.play("idle")
		body.set_checkpoint(global_position)

		
