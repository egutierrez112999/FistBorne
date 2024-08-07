extends RichTextLabel

func _process(_delta):
	if GameManager.multiplayer_active and GameManager.changeText:
		UpdateGameData.rpc()

func format_player_data():
	#formats data tracked in GameManager.players to be fed to the main damage label
	var formatted_str = ""
	var player_deets = GameManager.players
	for p in player_deets:
		formatted_str = formatted_str + str(player_deets[p].name) + ": "
		formatted_str = formatted_str + "health - " + str(player_deets[p].health) + "\n"
		#formatted_str = formatted_str + "M.R. - " + str(player_deets[p].metal_reserves) + "\n"
	return formatted_str
	
	
func _ready():
	UpdateGameData.rpc()


@rpc("any_peer","call_local","unreliable") func UpdateGameData():
	#a global rpc to be called by any other rpc to update the game data (score, health, metal_reserves, etc..)
	text = format_player_data()
	GameManager.changeText = false
