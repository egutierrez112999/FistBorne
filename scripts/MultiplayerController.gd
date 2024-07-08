extends Control

@export var Address = "127.0.0.1"
@export var Port = 9999
var peer

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connected_failed)

#called on server and clients when a peer connects
func peer_connected(id):
	print("Player Connected "+str(id))
	
#called on server and clients when a peer disconnects
func peer_disconnected(id):
	print("Player Disconnected "+str(id))

#called only from clients  client-> server
func connected_to_server():
	print("Connected to Server!")
	send_player_info.rpc_id(1,$LineEdit.text, multiplayer.get_unique_id())

#called only from clients
func connected_failed():
	print("Couldn't Connect")
	
	
@rpc("any_peer") func send_player_info(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
		"name": name,
		"id":id,
		"score" : 0,
		"health": 100,
		"metal_reserves":100,
		"player": null
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_info.rpc(GameManager.players[i].name, i)

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, 4)#4 player game. 
	if error != OK:
		print("Cannot Host: "+str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	#we set peer as host before, then we use host as our peer
	multiplayer.set_multiplayer_peer(peer)
	send_player_info($LineEdit.text, multiplayer.get_unique_id())
	print("waiting for players")


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer


func _on_start_game_button_down():
	StartGame.rpc()
	
@rpc("any_peer","call_local") func StartGame():
	var scene = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _process(_delta):
	for p in GameManager.players:
		if GameManager.players[p].health <= 0:
			pass
			#DeathAlert.rpc(GameManager.players[p].id)
			
@rpc("authority","call_local") func DeathAlert(player_id):
	pass
	#print("Player "+str(player_id)+" has died")
	#get_node(GameManager.players[player_id].player).queue_free()
			
