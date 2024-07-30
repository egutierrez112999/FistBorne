extends Area2D


const SPEED = 300.0
#@onready var timer = $Timer
#var can_attack = true
var direction: Vector2
var coin_owner_id

func _ready():
	if GameManager.multiplayer_active:
		$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())	
	
func _physics_process(delta):
	if GameManager.multiplayer_active:
		position.x += (direction[0] * SPEED * delta)

func _on_body_entered(body):
	if GameManager.multiplayer_active:
		RangedRequest.rpc_id(1, coin_owner_id, body.network_id)
		#self.queue_free()

@rpc("any_peer","call_local","reliable") func RangedRequest(coin_owner_id, defender_body_id):
	var attacker_id = coin_owner_id
	if attacker_id != defender_body_id:
		print("Ranged Hit")
		#print(GameManager.players)
		#print(str(attacker_id))
		#print(str(defender_body_id))
		GameManager.players[attacker_id].score += 1
		RangedDamage.rpc_id(0, defender_body_id)
	GameManager.changeText = true
	GameManager.players = GameManager.players
	self.queue_free()
		
@rpc("any_peer","call_local") func RangedDamage(defender_id):
		GameManager.players[defender_id].health -= 20
