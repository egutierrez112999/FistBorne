extends Area2D


const SPEED = 300.0
var direction: Vector2
var coin_owner_id

func _ready():
	#set the multiplayer authority of the coin only if multiplayer is active
	if GameManager.multiplayer_active:
		$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())	
	
func _physics_process(delta):
	if GameManager.multiplayer_active:
		#move the coin every frame in the direction the player was facing
		position.x += (direction[0] * SPEED * delta)

func _on_body_entered(body):
	if GameManager.multiplayer_active:
		RangedRequest.rpc_id(1, coin_owner_id, body.network_id)
		#self.queue_free()

@rpc("any_peer","call_local","reliable") func RangedRequest(coin_owner_id, defender_body_id):
	var attacker_id = coin_owner_id
	#check to make sure a peer is not hitting themselves
	if attacker_id != defender_body_id:
		print("Ranged Hit")
		GameManager.players[attacker_id].score += 1
		RangedDamage.rpc_id(0, defender_body_id)
	#change text for all players
	GameManager.changeText = true
	#Update player data for all peers
	GameManager.players = GameManager.players
	#remove the coin and its children from the tree
	self.queue_free()
		
@rpc("any_peer","call_local") func RangedDamage(defender_id):
		#set damage for them on all peers
		GameManager.players[defender_id].health -= 20
