extends Area2D

signal coldheart_died


@onready var sprite = $AnimatedSprite2D
@onready var collider = $CollisionShape2D

var is_dying = false

func _ready():
	sprite.play("idle")

func _on_body_entered(body):
	if is_dying:
		return

	if body.is_in_group("player"):
		is_dying = true
		print("Enemy touched by:", body.name)
		sprite.play("hurt")
		await sprite.animation_finished
		sprite.play("death")
		await sprite.animation_finished

		# Stay on last frame of death animation
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("death") - 1
		

		# Optionally disable collision so the player can't trigger it again
		collider.disabled = true
		print("Emitting coldheart_died signal")
		emit_signal("coldheart_died")
