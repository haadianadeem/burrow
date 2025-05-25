extends Area2D

@export var boost_strength: float = 450.0  # Adjust as needed

func _on_body_entered(body):
	if body.is_in_group("player"):  # you're already adding player to this group
		body.boost_jump(boost_strength)
