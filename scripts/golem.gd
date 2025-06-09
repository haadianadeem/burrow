extends Area2D

@export var speed := 40.0
@export var patrol_distance := 150.0

var direction := -1
var start_position := Vector2.ZERO
var player_in_range: bool = false

enum State { PATROLLING, ATTACKING }
var state = State.PATROLLING
var is_attacking := false

func _ready():
	start_position = position
	$AnimationPlayer.stop()

func _physics_process(delta):
	if state == State.PATROLLING:
		patrol(delta)

func patrol(delta):
	if $AnimatedSprite2D.animation != "walk":
		$AnimatedSprite2D.play("walk")

	# Wall or ledge detection
	if $RayCast_Wall.is_colliding() or not $RayCast_Floor.is_colliding():
		direction *= -1
		scale.x = -1 if direction < 0 else 1
		$RayCast_Wall.position.x = abs($RayCast_Wall.position.x) * direction
		$RayCast_Floor.position.x = abs($RayCast_Floor.position.x) * direction

	# Move
	position.x += direction * speed * delta

func _on_player_detection_body_entered(body):
	if body.is_in_group("player") and state != State.ATTACKING:
		player_in_range = true
		turn_to_face(body.global_position)
		attack()

func _on_player_detection_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func attack():
	if is_attacking:
		return

	is_attacking = true
	state = State.ATTACKING
	$AnimatedSprite2D.play("attack")
	$AnimationPlayer.play("attack")

func finish_attack():
	is_attacking = false

	if player_in_range:
		attack()
	else:
		state = State.PATROLLING
		$AnimatedSprite2D.play("walk")

func turn_to_face(player_pos: Vector2):
	var delta_x = player_pos.x - global_position.x
	if (delta_x < 0 and direction > 0) or (delta_x > 0 and direction < 0):
		direction *= -1
		scale.x = -1 if direction < 0 else 1
		$RayCast_Wall.position.x = abs($RayCast_Wall.position.x) * direction
		$RayCast_Floor.position.x = abs($RayCast_Floor.position.x) * direction

func activate_killzone():
	$KillzoneFlipper/Killzone.monitoring = true
	$KillzoneFlipper/Killzone/CollisionShape2D.set_deferred("disabled", false)

func deactivate_killzone():
	print("killzone deactivated")
	$KillzoneFlipper/Killzone.monitoring = false
	$KillzoneFlipper/Killzone/CollisionShape2D.set_deferred("disabled", true)
