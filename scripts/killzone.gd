#killzone.gd

extends Area2D

@onready var timer: Timer = $Timer

var player_to_respawn: Node2D = null

func _ready():
	# Connect timeout signal once
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("You died!")
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").disabled = true
		body.visible = false

		# Store the player temporarily
		player_to_respawn = body

		timer.start()

func _on_timer_timeout() -> void:
	if player_to_respawn:
		Engine.time_scale = 1.0
		player_to_respawn.global_position = player_to_respawn.respawn_position
		player_to_respawn.get_node("CollisionShape2D").disabled = false
		player_to_respawn.visible = true
