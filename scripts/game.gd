extends Node2D

var players = {}

@export var player_scene : PackedScene
@onready var cam = $Camera2D

@export var Address = "127.0.0.1"
@export var Port = 123
var peer

@onready var join_button = $Join
@onready var host_button = $Host

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
	send_player_info.rpc_id(1,"Banana", multiplayer.get_unique_id())

#called only from clients
func connected_failed():
	print("Couldn't Connect")

@rpc("any_peer") func send_player_info(name, id):
	if !Game.players.has(id):
		Game.players[id] = {
		"name": name,
		"id":id,
		"score" : 0
		}
	if multiplayer.is_server():
		for i in Game.players:
			send_player_info.rpc(Game.players[i].name, i)

func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, 4)#4 player game. 
	if error != OK:
		print("Cannot Host: "+str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	#we set peer as host before, then we use host as our peer
	multiplayer.set_multiplayer_peer(peer)
	send_player_info("server", multiplayer.get_unique_id())
	print("waiting for players")
	
	host_button.disabled = true
	join_button.disabled = true

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	
	join_button.disabled = true
	host_button.disabled = true
	
	
#####################COMBAT LOGIC#####################

@rpc("any_peer", "call_local","reliable") func check_attack(attack_type, player_id):
	if attack_type == 1:
		print("Attempting Melee Attack by "+str(player_id))

