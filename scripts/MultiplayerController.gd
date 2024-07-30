extends Control

@export var Address = "127.0.0.1"
@export var Port = 9999
var peer
var scene
var game_active = true

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connected_failed)
	multiplayer.server_disconnected.connect(server_disconnected)

#called on server and clients when a peer connects
func peer_connected(id):
	print("Player Connected "+str(id))
	
#called on server and clients when a peer disconnects
func peer_disconnected(id):
	#for n in get_tree().root.get_children():
		#n.queue_free()	
	#GameManager.players[id].player.queue_free()
	#GameManager.multiplayer_active = false
	#GameManager.players = {}
	GameManager.players[id].player.queue_free()
	#GameManager.players.erase(id)
	#get_tree().change_scene_to_file("res://scenes/control.tscn")
	print("Player Disconnected "+str(id))

func server_disconnected():
	if multiplayer.get_unique_id():
		GameManager.players[multiplayer.get_unique_id()].player.queue_free()
		multiplayer.multiplayer_peer.close()
	GameManager.multiplayer_active = false
	GameManager.players = {}
	get_tree().change_scene_to_file("res://scenes/control.tscn")
	print("server disconnected")
	
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
		"health": 150,
		"metal_reserves":100,
		"player": null
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_info.rpc(GameManager.players[i].name, i)

func _on_host_button_down():
	GameManager.multiplayer_active = true
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
	GameManager.multiplayer_active = true
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer


func _on_start_game_button_down():
	StartGame.rpc()
	
@rpc("any_peer","call_local") func StartGame():
	scene = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()


@rpc("authority","call_local") func EndGame():
	GameManager.multiplayer_active = false
	multiplayer.multiplayer_peer.close()
	#scene = load("res://scenes/control.tscn").instantiate()
	#get_tree().root.add_child(scene)
	#GameManager.players = {}
	#self.hide()

		
#@rpc("any_peer","call_local") func 

func _process(_delta):
	if game_active:
		for p in GameManager.players:
			if GameManager.players[p].health <= 0:
				GameManager.multiplayer_active = false
				game_active = false
				EndGame.rpc_id(1)

#yield(get_tree().create_timer(0.1),"timeout"
