extends Node

var players_data: Array[PlayerData]
var allChatMessages: Array[Message] =  []

var selected_character: PackedScene

func update_player_data(player_data:PlayerData):
	var player_index = get_player_index(player_data.PeerId)
	if player_index > -1:
		players_data[player_index] == player_data
	else:
		players_data.push_back(player_data)
		
	
func get_player_index(peer_id:int) -> int:
	var playerCounter = 0
	var found_index = -1
	for player_data in players_data:
		if(player_data.PeerId == peer_id):
			found_index = playerCounter
		playerCounter +=1	
	return found_index
	
func get_player_data(peer_id:int) -> PlayerData:
	for player_data in players_data:
		if(player_data.PeerId == peer_id):
			return player_data
	return null	
