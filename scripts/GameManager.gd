extends Node
#####This is a global script#####


#player data tracked on all peers
var players = {} 
#super jank solution to updating the text only when i want to
var changeText = false
#Used to make sure certain actions happen only when multiplayer is active
var multiplayer_active = false
