extends CharacterBody2D


const SPEED = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())	
	
	
func _physics_process(delta):
	velocity = SPEED * direction
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
