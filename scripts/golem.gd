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
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

	
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
		scale.x = -1 if direction < 0 else 1
		#$AnimatedSprite2D.flip_h = direction > 0
		#$KillzoneFlipper.scale.x = -1 if direction > 0 else 1


func _on_player_detection_body_entered(body):
	if body.is_in_group("player") and state != State.ATTACKING:
		player_in_range = true
		turn_to_face(body.global_position)
		attack()
		
func turn_to_face(player_pos: Vector2):
	var delta_x = player_pos.x - global_position.x
	if (delta_x < 0 and direction > 0) or (delta_x > 0 and direction < 0):
		direction *= -1
		scale.x = -1 if direction < 0 else 1

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
	
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		finish_attack()

func finish_attack():
	is_attacking = false
	# Don't stop animation manually; it has already finished
	
	if player_in_range:
		$AttackCooldownTimer.start()
	else:
		state = State.PATROLLING
		$AnimatedSprite2D.play("walk")
		
	
func activate_killzone():
	$KillzoneFlipper/Killzone.monitoring = true
	$KillzoneFlipper/Killzone/CollisionShape2D.set_deferred("disabled", false)
	

func deactivate_killzone():
	print("killzone deactivated")
	$KillzoneFlipper/Killzone.monitoring = false
	$KillzoneFlipper/Killzone/CollisionShape2D.set_deferred("disabled", true)

func return_to_patrol():
	if player_in_range:
		attack()  # Will only work if attack is marked finished
	else:
		state = State.PATROLLING
		$AnimatedSprite2D.play("walk")


func _on_attack_cooldown_timer_timeout() -> void:
	if player_in_range and not is_attacking:
		attack()
