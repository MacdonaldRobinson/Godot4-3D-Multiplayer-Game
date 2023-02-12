extends Node3D

@onready var map_container = $MapContainer
@onready var lobby_manager_ui = $CanvasLayer/LobbyManagerUI
@onready var players_container = $PlayersContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func clear_map():
	for map in map_container.get_children():
		map_container.remove_child(map)
		
func clear_players():
	for player in players_container.get_children():
		players_container.remove_child(player)
		
func find_player(peer_id: int):
	for player in players_container.get_children():
		if player.name == str(peer_id):
			return player

func find_player_index(peer_id: int):
	var player_counter = 0;
	for player in players_container.get_children():
		if player.name == str(peer_id):
			return player_counter
		player_counter +=1

func _on_lobby_manager_ui_map_selected(map: Map):
	clear_map()			
	map_container.add_child(map)	
	print("_on_lobby_manager_ui_map_selected", map)


func _on_lobby_manager_ui_clear_map():
	print("_on_lobby_manager_ui_clear_map")
	clear_map()


func _on_lobby_manager_ui_added_player(player: Player):
	players_container.add_child(player)
	
	print("_on_lobby_manager_ui_added_player", player)
	

func _on_lobby_manager_ui_removed_player(peer_id):
	print("_on_lobby_manager_ui_removed_player", peer_id)
	var player = find_player(peer_id)
	
	if player:
		players_container.remove_child(player)
	


func _on_lobby_manager_ui_start_game(players):
	clear_players()
	
	var current_map = map_container.get_child(0)
	
	for player in players:
		players_container.add_child(player)
