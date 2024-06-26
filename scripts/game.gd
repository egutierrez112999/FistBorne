extends Node2D

var peer = ENetMultiplayerPeer.new()
var players = {}

@export var player_scene : PackedScene
@onready var cam = $Camera2D

@export var Address = "127.0.0.1"
@onready var join_button = $Join
@onready var host_button = $Host


func _on_host_pressed():
	peer.create_server(123)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	host_button.disabled = true
	join_button.disabled = true
	#cam.enabled = false

func connected_to_server():
	print("Connected to Server!")

func _on_join_pressed():
	peer.create_client(Address, 123)
	multiplayer.multiplayer_peer = peer
	join_button.disabled = true
	host_button.disabled = true
	#cam.enabled = false


func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	
func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)
	
func del_player(id):
	rpc("_del_player",id)
	
@rpc("any_peer", "call_local") func _del_player(id):
	get_node(str(id)).queue_free()
	

