extends Area2D

func _on_body_entered(body):
	var player_id = body.network_id
	GameManager.players[player_id].metal_reserves = 100
	MetalPickup.rpc()
	print("coin picked up")
	
@rpc("any_peer","call_local","unreliable") func MetalPickup():
	self.queue_free()
	GameManager.players = GameManager.players
