extends Area2D

@onready var timer = $Timer
var can_attack = true

func _on_body_entered(body):
	if can_attack:
		can_attack = false
		timer.start()
		MeleeRequest.rpc_id(1, body.get_multiplayer_authority())


@rpc("any_peer","call_local","reliable") func MeleeRequest(defender_body_id):
	var attacker_id = multiplayer.get_remote_sender_id()
	if attacker_id != defender_body_id:
		var attacker_pos = GameManager.players[attacker_id].player.global_position 
		var defender_pos = GameManager.players[defender_body_id].player.global_position 
		if (abs(attacker_pos[0]-defender_pos[0]) < 20) and (abs(attacker_pos[1]-defender_pos[1]) < 20):
			print("SUCCESsFUL HITT")
			GameManager.players[attacker_id].score += 1
			GameManager.players[defender_body_id].health -= 30
	#for p in get_tree().get_nodes_in_group("player"):
	#	print(p.get_multiplayer_authority())
	#var defender_id = 


func _on_timer_timeout():
	can_attack = true
	
