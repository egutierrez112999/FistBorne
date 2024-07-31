extends Area2D

func _on_body_entered(body):
	#Replenish the metal reserves of the pllayer
	var player_id = body.network_id
	GameManager.players[player_id].metal_reserves = 100
	MetalPickup.rpc()
	print("coin picked up")
	
@rpc("any_peer","call_local","unreliable") func MetalPickup():
	#Remove the metal vial for everyone and sync player data
	self.queue_free()
	GameManager.players = GameManager.players
