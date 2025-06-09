extends Area2D

@export var speed: float = 200.0
@export var direction: Vector2 = Vector2.LEFT
#@export var lifetime: float = 3.0  # Seconds before self-destruct

var start_position: Vector2
var is_active: bool = false

func _ready():
	start_position = position
	$VisibleOnScreenNotifier2D.connect("screen_entered", Callable(self, "_on_screen_entered"))

func _on_screen_entered():
	is_active = true
	
func _process(delta):
	if is_active:
		position += direction.normalized() * speed * delta
		


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	pass # Replace with function body.
	
func reset():
	position = start_position
	is_active = false
