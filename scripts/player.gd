#player.gd

extends CharacterBody2D


var SPEED = 130.0
var JUMP_VELOCITY = -300.0
var acceleration = 70.0
var max_speed = 350.0
var current_speed = SPEED
var last_direction = 0
var current_animation = ""
var respawn_position: Vector2



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var amount = $HUD/Coins/Amount
@onready var quest_tracker = $HUD/QuestTracker
@onready var title = $HUD/QuestTracker/Details/Title
@onready var objectives = $HUD/QuestTracker/Details/Objectives
@onready var quest_manager = $QuestManager

var can_move = true

# Dialog & Quest vars
var selected_quest: Quest = null
var coin_amount = 0

func _ready():
	Global.player = self
	respawn_position = global_position
	quest_tracker.visible = false
	update_coins()

	
	# Signal connections
	quest_manager.quest_updated.connect(_on_quest_updated)
	quest_manager.objective_updated.connect(_on_objective_updated)
	

func _physics_process(delta: float) -> void:
	if can_move: 
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		#turn raycast toward movement direction
		
		if velocity != Vector2.ZERO:
			ray_cast_2d.target_position = velocity.normalized() * 50
		

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("move_left", "move_right")
		
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
			
		#if is_on_floor(): 
		#	if direction == 0:
		#		animated_sprite.play("idle")
		#	else:
		#		animated_sprite.play("run")
		#else:
		#	animated_sprite.play("jump")
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		# Apply acceleration logic
		if direction != 0:
			# If switching direction, reset to base speed
			if direction != last_direction:
				current_speed = SPEED
			# Accelerate smoothly after the initial base speed
			current_speed = clamp(current_speed + acceleration * delta, SPEED, max_speed)
			velocity.x = direction * current_speed
			last_direction = direction  # Update the last direction
		else:
			# Immediately stop and go to idle if no input
			current_speed = 0
			velocity.x = 0
			last_direction = 0  
			if current_animation != "idle":
				current_animation = "idle"
				animated_sprite.play("idle")

		# Animation state switching based on speed
		if is_on_floor():
			if current_speed == 0 and current_animation != "idle":
				current_animation = "idle"
				animated_sprite.play("idle")
			elif current_speed > 0 and current_speed <= 250 and current_animation != "walk":
				current_animation = "walk"
				animated_sprite.play("walk")
			elif current_speed > 250 and current_animation != "run":
				current_animation = "run"
				animated_sprite.play("run")
		else:
			if current_animation != "jump":
				current_animation = "jump"
				animated_sprite.play("jump")

		move_and_slide()
		
func set_checkpoint(position: Vector2):
	respawn_position = position


func _input(event):
	#Interact with NPC/ Quest Item
	if can_move:
		if event.is_action_pressed("ui_interact"):
			var target = ray_cast_2d.get_collider()
			if target != null:
				if target.is_in_group("NPC"):
					can_move = false
					target.start_dialog()
					check_quest_objectives(target.npc_id, "talk_to")
				elif target.is_in_group("Item"):
					if is_item_needed(target.item_id):
						check_quest_objectives(target.item_id, "collection", target.item_quantity)
						target.queue_free()
					else: 
						print("Item not needed for any active quest.")
	# Open/close quest log
		if event.is_action_pressed("ui_quest_menu"):
			quest_manager.show_hide_log()
					
# Check if quest item is needed
func is_item_needed(item_id: String) -> bool:
	if selected_quest != null:
		for objective in selected_quest.objectives:
			if objective.target_id == item_id and objective.target_type == "collection" and not objective.is_completed:
				return true				
	return false
	
func check_quest_objectives(target_id: String, target_type: String, quantity: int = 1):
	if selected_quest == null:
		return
	
	# Update objectives
	var objective_updated = false
	for objective in selected_quest.objectives:
		if objective.target_id == target_id and objective.target_type == target_type and not objective.is_completed:
			print("Completing objective for quest: ", selected_quest.quest_name)
			selected_quest.complete_objective(objective.id, quantity)
			objective_updated = true
			break
	
	# Provide rewards
	if objective_updated:
		if selected_quest.is_completed():
			handle_quest_completion(selected_quest)
	
		# Update UI
		update_quest_tracker(selected_quest)
	
# Player rewards
func handle_quest_completion(quest: Quest):
	for reward in quest.rewards:
		if reward.reward_type == "coins":
			coin_amount += reward.reward_amount
			update_coins()
	update_quest_tracker(quest)
	quest_manager.update_quest(quest.quest_id, "completed")
	
# Update coin UI
func update_coins():
	amount.text = str(coin_amount)
	
# Update tracker UI
func update_quest_tracker(quest: Quest):
	# if we have an active quest, populate tracker
	if quest:
		quest_tracker.visible = true
		title.text = quest.quest_name	
		
		for child in objectives.get_children():
			objectives.remove_child(child)
			
		for objective in quest.objectives:
			var label = Label.new()
			label.text = objective.description
			
			if objective.is_completed:
				label.add_theme_color_override("font_color", Color(0, 1, 0))
			else:
				label.add_theme_color_override("font_color", Color(1,0, 0))
				
			objectives.add_child(label)
	# no active quest, hide tracker		
	else:
		quest_tracker.visible = false

# Update tracker if quest is complete
func _on_quest_updated(quest_id: String):
	var quest = quest_manager.get_quest(quest_id)
	if quest == selected_quest:
		update_quest_tracker(quest)
	selected_quest = null
	
# Update tracker if objective is complete
func _on_objective_updated(quest_id: String, objective_id: String):
	if selected_quest and selected_quest.quest_id == quest_id:
		update_quest_tracker(selected_quest)
	selected_quest = null
	
	
	
	
	
	
	
