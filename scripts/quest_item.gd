### QuestItem.gd
@tool
extends Area2D

@onready var sprite_2d = $Sprite2D

# Vars
@export var item_id: String = ""
@export var item_quantity: int = 1
@export var item_icon = Texture2D

func _ready():
	connect("body_entered", _on_body_entered)
	# Show texture in game
	if not Engine.is_editor_hint():
		sprite_2d.texture = item_icon
		
func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.is_item_needed(item_id):
			body.check_quest_objectives(item_id, "collection", item_quantity)
			queue_free()
		else:
			print("Item not needed for any active quest.")

func _process(delta):
	# Show texture in engine
	if Engine.is_editor_hint():
		sprite_2d.texture = item_icon
		
