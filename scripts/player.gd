extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
var can_attack = true #THis will be used to tell when a player can attack
var health = 100
var network_id

var syncPos = Vector2(0,0)

var syncDirection = 0 #work on this one later to flip animations
@onready var animated_sprite = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		syncPos = global_position
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
			$killzone/CollisionShape2D2.position = Vector2(11.5, 0)
		elif direction < 0:
			animated_sprite.flip_h = true
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

		move_and_slide()
	else:
		global_position = global_position.lerp(syncPos, .5)

func _process(_delta):
	if Input.is_action_just_pressed("melee_attack"):
		pass


