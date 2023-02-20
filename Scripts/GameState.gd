extends Node

var players_data: Array[PlayerData]
var allChatMessages: Array[Message] =  []

var selected_character: PackedScene
var is_game_started: bool

func print_stats():
	print("-----Start: Print Stats ------")
	for player_data in players_data:
		print("PeerId: ", player_data.PeerId, " | Health: ", player_data.Health)
	print("-----End: Print Stats ------")
	
func update_player_data(player_data:PlayerData):
	var player_index = get_player_index(player_data.PeerId)
	if player_index != -1:		
		#print_stats()
		players_data[player_index] = player_data	
		#print_stats()	
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
