extends Area2D

@onready var timer = $Timer
var hits = 1
func _on_body_entered(body):
	var m_auth = get_multiplayer_authority()
	if body.get_multiplayer_authority() != m_auth:
		print(str(m_auth)+"You have been hit " + str(hits))
		hits +=1
	#body.get_node("CollisionShape2D").queue_free()
	#timer.start()



func _on_timer_timeout():
	get_tree().reload_current_scene()
