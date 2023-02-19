extends Node
class_name Lobby

@onready var map_container: Node= $MapContainer
@onready var lobby_manager_ui: LobbyManagerUI = $LobbyManager/LobbyManagerUI

@export var player_scene: PackedScene

var selected_character: PackedScene 
var selected_map: Map3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	pass

func clear_map():
	for map in map_container.get_children():
		map_container.remove_child(map)
		
func clear_players():
	if !selected_map: return
	
	var players_container = selected_map.get_players_container()
	
	for player in players_container.get_children():
		players_container.remove_child(player)
		
func find_player(peer_id: int):
	if !selected_map:
		return
		
	var players_container = selected_map.get_players_container()
			
	for player in players_container.get_children():
		if player.name == str(peer_id):
			return player

func find_player_index(peer_id: int):
	var players_container = selected_map.get_players_container()
		
	var player_counter = 0;
	for player in players_container.get_children():
		if player.name == str(peer_id):
			return player_counter
		player_counter +=1

func _on_lobby_manager_ui_map_selected(map: Node):
	#clear_map()			
	#map_container.add_child(map)	
	print("_on_lobby_manager_ui_map_selected", map)


func _on_lobby_manager_ui_clear_map():
	print("_on_lobby_manager_ui_clear_map")
	clear_map()


func _on_lobby_manager_ui_added_player(player_data: PlayerData):
	print("_on_lobby_manager_ui_added_player", player_data)
	

func _on_lobby_manager_ui_removed_player(peer_id):
	print("_on_lobby_manager_ui_removed_player", peer_id)
	var player = find_player(peer_id)
	var players_container = selected_map.get_players_container()
	
	if player:
		players_container.remove_child(player)
		

func _on_lobby_manager_ui_start_game(map:Map3D, players_data:Array[PlayerData]):
	clear_map()

	selected_map = map
	map_container.add_child(selected_map)
	
	clear_players()
	var players_container = selected_map.get_players_container()	

	for player_data in players_data:
		var player_instance = player_scene.instantiate()
		player_instance.name = str(player_data.PeerId)
		player_instance.set_player_data(player_data)

		players_container.add_child(player_instance)

	lobby_manager_ui.hide()


func _on_lobby_manager_ui_updated_player_data(player_data: PlayerData):
	var player = find_player(player_data.PeerId)
	
	if player:
		player.set_player_data(player_data)
	

func _on_lobby_manager_ui_server_disconnected():
	clear_map()
	lobby_manager_ui.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
