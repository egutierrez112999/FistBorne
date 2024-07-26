extends Area2D

var active

func collision_detection():
	if has_overlapping_bodies() and active:
		var body_list = get_overlapping_bodies()
		#print(body_list)
		for body in body_list:
			MeleeRequest.rpc_id(1, body.network_id)

#func _on_body_entered(body):
#	if active:
#		print("Attack registered")
#		MeleeRequest.rpc_id(1, body.network_id)

@rpc("any_peer","call_local","reliable") func MeleeRequest(defender_body_id):
	var attacker_id = multiplayer.get_remote_sender_id()
	if attacker_id != defender_body_id:
		var attacker_pos = GameManager.players[attacker_id].player.global_position
		var defender_pos = GameManager.players[defender_body_id].player.global_position
		if (abs(attacker_pos[0]-defender_pos[0]) < 20) and (abs(attacker_pos[1]-defender_pos[1]) < 20):
			print("Melee Hit")
			#print(GameManager.players)
			#print(str(attacker_id))
			#print(str(defender_body_id))
			GameManager.players[attacker_id].score += 1
			TakeDamage.rpc_id(0, defender_body_id)
	GameManager.changeText = true
	GameManager.players = GameManager.players
		
@rpc("any_peer","call_local") func TakeDamage(defender_id):
		GameManager.players[defender_id].health -= 30

