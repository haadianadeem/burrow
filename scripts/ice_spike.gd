#ice_spike.gd

extends Area2D

@export var speed: float = 200.0
@export var direction: Vector2 = Vector2.LEFT

@export var warning_time: float = 1.0
@export var warning_side: String = "right" 

var warning_instance: Node = null

var start_position: Vector2
var is_active: bool = false

func _ready():
	start_position = position
	show_warning()
	$VisibleOnScreenNotifier2D.connect("screen_entered", Callable(self, "_on_screen_entered"))

func show_warning():
	var root = get_tree().get_root()
	print("Root node: ", root.name)
	
	if not root.has_node("Game/UI/WarningIndicator"):
		print("WARNING: Path Game/UI/WarningIndicator not found!")
		for child in root.get_children():
			print("Root child: ", child.name)
		return
	
	var warning_path = "Game/UI/WarningIndicator"
	var warning_node = root.get_node(warning_path)
	print("Found node at path: ", warning_path, " — node name: ", warning_node.name)

	warning_node.show_warning(warning_side, warning_time)

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
