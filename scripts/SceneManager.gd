extends Node2D


@export var player_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	#Do this process for each peer(player)
	for i in GameManager.players:
		#Create the player node and add it to the tree
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.players[i].id)
		add_child(current_player)
		#add management player data to the GameManager
		GameManager.players[i].player = current_player
		current_player.network_id = GameManager.players[i].id
		#Spawn each player at a given spawnpoint
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index +=1


