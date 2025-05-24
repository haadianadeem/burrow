extends Node2D

const SPEED = 60

var direction = 1
var hits_taken = 0
var is_dead = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta


func _on_body_entered(body: Node) -> void:
	if is_dead:
		return

	if body.name == "Player": # Adjust based on your player node name
		var player_velocity = body.get("velocity") # Or however you track player motion

		# If player is falling (adjust logic depending on your setup)
		if player_velocity.y > 0 and body.global_position.y < global_position.y:
			# Stomped from above
			hits_taken += 1
			if hits_taken == 1:
				animated_sprite.play("blink")
			elif hits_taken == 2:
				animated_sprite.play("die")
				is_dead = true
				queue_free() # Or remove/hide collision
			# Bounce player upward a bit
			body.set("velocity", Vector2(player_velocity.x, -200)) # Replace with your method
		else:
			# Player hit from side = death
			body.call("die") # Or your method to kill the player
