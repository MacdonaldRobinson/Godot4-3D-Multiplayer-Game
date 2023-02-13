extends Control
class_name LobbyManagerUI

@onready var host_port_number = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/PortNumber/PortNumberInput
@onready var map_selector = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/SelectMap/SelectMapInput
@onready var players_list = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/PlayersList
@onready var join_ip_address = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Join/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/IPAddressFields/IPAddressInput
@onready var join_port_number = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Join/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/JoinPortNumberFields/JoinPortNumberInput
@onready var host_external_ip_address = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/ExternalIP/ExternalIPInput
@onready var start_game = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/StartGameButton

@export var player_packed_scene:PackedScene
@export var map_packed_scenes:Array[PackedScene]

var selected_map_index = 0
var map_scenes: Array[Map]
var players: Array[Player]

var enet_peer = ENetMultiplayerPeer.new()

signal MapSelected(map:Map)
signal ClearMap()
signal AddedPlayer(player:Player)
signal RemovedPlayer(peer_id:int)
signal StartGame(players:Array[Player])

func _ready():	
	for map_packed_scene in map_packed_scenes:
		var scene_instance:Map = map_packed_scene.instantiate()
		map_scenes.push_back(scene_instance)	
		map_selector.add_item(scene_instance.name)	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_host_button_pressed():
	players_list.clear()
	
	enet_peer.create_server(int(host_port_number.text))
	multiplayer.multiplayer_peer = enet_peer
	
	var host_peer_id:int = multiplayer.get_unique_id()
	
	EmmitMapSelected(selected_map_index)
	add_player(host_peer_id)
	
	setup_upnp()
	
	map_selector.disabled = false
	start_game.disabled = false	
	
	enet_peer.peer_connected.connect(
		func(peer_id):
			add_player(peer_id)
			var existing_player_ids = get_existing_player_ids()

			await get_tree().create_timer(1).timeout			
			EmmitMapSelected.rpc(selected_map_index)
			add_existing_players.rpc(existing_player_ids)
	)
	enet_peer.peer_disconnected.connect(		
		func(peer_id):
			remove_player(peer_id)
			await get_tree().create_timer(1).timeout
			remove_player.rpc(peer_id)
	)
	
func _on_join_button_pressed():
	players_list.clear()
	enet_peer.create_client(join_ip_address.text, int(join_port_number.text))
	multiplayer.multiplayer_peer = enet_peer

func get_existing_player_ids() -> Array[int]:
	var existing_player_ids:Array[int] = []
	for player in players:
		existing_player_ids.push_back(player.name.to_int())
		
	return existing_player_ids
	
@rpc
func add_existing_players(existing_peer_ids):
	for existing_peer_id in existing_peer_ids:
		var found_player_index = get_player_index(existing_peer_id)
		if found_player_index == -1:
			add_player(existing_peer_id)

func add_player(peer_id):
	
	print("add_player", peer_id)
	var player = player_packed_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
		
	players.push_back(player)
	players_list.add_item(player.name)
		
	#emit_signal("AddedPlayer", player)

@rpc
func remove_player(peer_id) -> int:
	print("remove_player", peer_id)
	var found_player_index = get_player_index(peer_id)
	
	if(found_player_index > -1):
		players.remove_at(found_player_index)
		players_list.remove_item(found_player_index)	
	
	RemovedPlayer.emit(peer_id)	
	
	return found_player_index
	
func get_player_index(peer_id:int) -> int:
	var playerCounter = 0
	var found_index = -1
	for player in players:
		if(player.name == str(peer_id)):
			found_index = playerCounter
		playerCounter +=1	
	return found_index
	
@rpc
func EmmitMapSelected(map_scene_index: int):	
	print("EmmitMapSelected", map_scene_index)
	map_selector.select(map_scene_index)
	
	if(map_scenes.size() > 0):
		MapSelected.emit(map_scenes[map_scene_index])		
	else:	
		ClearMap.emit()		


func _on_select_map_input_item_selected(index):	
	selected_map_index = index
	MapSelected.emit(map_scenes[index])	
	EmmitMapSelected.rpc(index)	
	
func _on_item_list_property_list_changed():
	print("_on_item_list_property_list_changed")


func _on_start_game_button_pressed():
	StartGame.emit(players)	
	
func setup_upnp():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discovery Failed")

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway() , "UPNP Invalid Gateway")
	
	var map_result = upnp.add_port_mapping(int(host_port_number.text))
	
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed")

	print("Successfully Join Address ")	
	
	host_external_ip_address.text = upnp.query_external_address()
	
