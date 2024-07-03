extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
var can_attack = true #THis will be used to tell when a player can attack
var health = 100

@onready var animated_sprite = $AnimatedSprite2D 
@onready var melee_collision_shape = $killzone/CollisionShape2D2
@onready var att_timer = $att_timer


var eDelta = 0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	#player_cam.enabled = is_multiplayer_authority()


func _physics_process(delta):
	eDelta = delta
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta

		# Handle jump.
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input directio: -1,0,1
		var direction = Input.get_axis("move_left", "move_right")
		#flip the sprite
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
	
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

		move_and_slide()
		
@rpc("unreliable","any_peer","call_local") func updatePos(id,pos):
	if !is_multiplayer_authority():
		if name ==id:
			position = lerp(position, pos, eDelta*15)
			

func _on_timer_timeout():
	if is_multiplayer_authority():
		rpc("updatePos", name, position)
		
		
func _process(_delta):
	if Input.is_action_just_pressed("melee_attack") && can_attack:
		can_attack = false
		rpc('try_melee_attack')
		
@rpc("any_peer","call_local","reliable") func try_melee_attack():
	rpc("check_attack", 1, get_multiplayer_authority())
	#att_timer.start()
	#print("Timer Started")
	#melee_collision_shape.disabled = false
	#animated_sprite.play("melee")

func _on_att_timer_timeout():
	print("timer timeout")
	melee_collision_shape.disabled = true
	can_attack = true
