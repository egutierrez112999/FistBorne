extends Area2D

@onready var timer = $Timer
var hits = 1
func _on_body_entered(body):
	var my_auth = get_multiplayer_authority()
	var body_auth = body.get_multiplayer_authority()
	if body_auth != my_auth:
		print(str(my_auth)+"You have hit " + str(body_auth))
		print(str(name)+"You have hit " + str(body.name))
		hits +=1
	#body.get_node("CollisionShape2D").queue_free()
	#timer.start()

#@rpc("any_peer","call_local","reliable") func damage_calculation():
#if !is_multiplayer_authority():
#		if name ==id:
#			position = lerp(position, pos, eDelta*15)

func _on_timer_timeout():
	get_tree().reload_current_scene()
