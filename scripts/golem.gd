extends Area2D

@export var speed := 40.0
@export var patrol_distance := 150.0

var direction := -1
var start_position := Vector2.ZERO
var player_in_range: bool = false

enum State { PATROLLING, ATTACKING }
var state = State.PATROLLING

func _ready():
	start_position = position
	#$Killzone.monitoring = false
	#$Killzone.disabled = true

func _physics_process(delta):
	if state == State.PATROLLING:
		patrol(delta)

func patrol(delta):
	if $AnimatedSprite2D.animation != "walk":
		$AnimatedSprite2D.play("walk")
		
	position.x += direction * speed * delta
	
	if abs(position.x - start_position.x) >= patrol_distance:
		direction *= -1
		$AnimatedSprite2D.flip_h = direction > 0

func _on_player_detection_body_entered(body):
	if body.is_in_group("player") and state != State.ATTACKING:
		player_in_range = true
		attack()

func _on_player_detection_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func attack():
	state = State.ATTACKING
	$AnimatedSprite2D.play("attack")
	$AnimationPlayer.play("attack")  # handles killzone activation/deactivation + return

func activate_killzone():
	print("killzone activated")
	$Killzone.monitoring = true
	$Killzone/CollisionShape2D.set_deferred("disabled", false)

func deactivate_killzone():
	print("killzone deactivated")
	$Killzone.monitoring = false
	$Killzone/CollisionShape2D.set_deferred("disabled", true)

func return_to_patrol():
	if player_in_range:
		attack()  # Repeat attack if player still in range
	else:
		state = State.PATROLLING
		$AnimatedSprite2D.play("walk")
