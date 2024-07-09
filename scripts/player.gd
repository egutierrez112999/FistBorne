extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
var can_attack = true #THis will be used to tell when a player can attack
var health = 100
var network_id
var metal_movement_x
var metal_movement_y
#var iron_active = false
#var steel_active = false

var syncPos = Vector2(0,0)

var syncDirection = 1 #work on this one later to flip animations
@onready var animated_sprite = $AnimatedSprite2D
@export var coin_shot: PackedScene

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func normalize(value, min, max):
	return abs((value-min)/(max-min))

func tp(value, min, max):
	var n = normalize(value, min, max)
	return n*(abs(max-min)+min)
	

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		syncPos = global_position
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
		# Handle jump.
		if Input.is_action_just_pressed("burn_iron"):
			var mouse_coords = get_viewport().get_mouse_position()
			var window_size = get_viewport().get_window().size
			#( src - src_min ) / ( src_max - src_min ) * ( res_max - res_min ) + res_min
			var new_y = (( mouse_coords.y - 0 ) / ( window_size.y - 0 ) * ( 47 +80 ) - 80)
			var new_x = (( mouse_coords.x - 0 ) / ( window_size.x - 0 ) * ( 360 - 6 ) + 6)
			if ((new_y < 47)and(new_y > -80)and(new_x < 360)and(new_x > 6)):
				#x logic
				if new_x > position.x:
					metal_movement_x = new_x-((new_x-position.x)/2)
				else:
					metal_movement_x = new_x+((position.x-new_x)/2)
				#y logic
				if new_y > position.y:
					metal_movement_y = position.y+(abs(new_y-position.y)/2)
				else:
					metal_movement_y = position.y-(abs(position.y-new_y)/2)
				#make sure changes are withing bounds
				if metal_movement_x > 360:
					metal_movement_x = 360
				elif metal_movement_x < 6:
					metal_movement_x = 6
				if metal_movement_y > 47:
					metal_movement_y = 47
				elif metal_movement_y < -80:
					metal_movement_y = -80
				position.y = metal_movement_y
				position.x = metal_movement_x
		if Input.is_action_just_pressed("burn_steel"):
			var mouse_coords = get_viewport().get_mouse_position()
			var window_size = get_viewport().get_window().size
			#( src - src_min ) / ( src_max - src_min ) * ( res_max - res_min ) + res_min
			var new_y = (( mouse_coords.y - 0 ) / ( window_size.y - 0 ) * ( 47 +80 ) - 80)
			var new_x = (( mouse_coords.x - 0 ) / ( window_size.x - 0 ) * ( 360 - 6 ) + 6)
			if ((new_y < 47)and(new_y > -80)and(new_x < 360)and(new_x > 6)):
				#x logic
				if new_x > position.x:
					metal_movement_x = position.x-((new_x-position.x)/2)
				else:
					metal_movement_x = position.x+((position.x-new_x)/2)
				#y logic
				if new_y > position.y:
					metal_movement_y = position.y-(abs(new_y-position.y)/2)
				else:
					metal_movement_y = position.y+(abs(position.y-new_y)/2)
				#make sure changes are withing bounds
				if metal_movement_x > 360:
					metal_movement_x = 360
				elif metal_movement_x < 6:
					metal_movement_x = 6
				if metal_movement_y > 47:
					metal_movement_y = 47
				elif metal_movement_y < -80:
					metal_movement_y = -80
				position.y = metal_movement_y
				position.x = metal_movement_x
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Get the input directio: -1,0,1
		var direction = Input.get_axis("move_left", "move_right")
		#flip the sprite
		if direction > 0:
			animated_sprite.flip_h = false
			syncDirection = 1
			$killzone/CollisionShape2D2.position = Vector2(11.5, 0)
			
		elif direction < 0:
			animated_sprite.flip_h = true
			syncDirection = -1
			$killzone/CollisionShape2D2.position = Vector2(-11.5, 0)
		#play animations
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
		#apply movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		
		if Input.is_action_just_pressed("ranged_attack"):
			SpawnBullet.rpc()

		move_and_slide()
	else:
		global_position = global_position.lerp(syncPos, .5)
		
		
@rpc("any_peer","call_local","unreliable") func SpawnBullet():
	var coin = coin_shot.instantiate()
	coin.direction = Vector2(syncDirection,0)
	coin.coin_owner_id = multiplayer.get_remote_sender_id()
	get_tree().root.add_child(coin)
	coin.global_position = $killzone/CollisionShape2D2.global_position



