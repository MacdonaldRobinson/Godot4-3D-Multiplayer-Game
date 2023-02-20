extends Control
class_name LobbyManagerUI

@onready var host_port_number:LineEdit  = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/HBoxContainer3/PortNumber/PortNumberInput
@onready var map_selector:OptionButton = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/HBoxContainer2/SelectMap/SelectMapInput
@onready var players_list:ItemList  = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/PlayersList
@onready var join_ip_address:LineEdit = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Join/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HBoxContainer2/IPAddressFields/IPAddressInput
@onready var join_port_number:LineEdit = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Join/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HBoxContainer2/JoinPortNumberFields/JoinPortNumberInput
@onready var host_external_ip_address:LineEdit = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/HBoxContainer/ExternalIP/ExternalIPInput
@onready var start_game:Button = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/HBoxContainer2/StartGameButton
@onready var host_player_name:LineEdit = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/HostPlayerName/HostPlayerNameInput
@onready var join_player_name:LineEdit = $Panel/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Join/PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/PlayerName/PlayerNameInput
@onready var chat: Chat = $Panel/VBoxContainer/MarginContainer/VBoxContainer/Chat

@export var map_packed_scenes:Array[PackedScene]

var selected_map_index = 0
var map_scenes: Array[Node]

var enet_peer = ENetMultiplayerPeer.new()

signal MapSelected(map:Node)
signal ClearMap()
signal AddedPlayer(player_data:PlayerData)
signal RemovedPlayer(peer_id:int)
signal StartGame(players_data:Array[PlayerData])
signal UpdatedPlayerData(player_data: PlayerData)
signal ServerConnected()
signal ServerDisconnected()
signal SpawnPlayer(player_data:PlayerData)

func _ready():	
	for map_packed_scene in map_packed_scenes:
		var scene_instance:Node = map_packed_scene.instantiate()
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
	
	rpc_emmit_map_selected(selected_map_index)
	
	var player_data: PlayerData = PlayerData.new()
	player_data.PeerId = host_peer_id
	player_data.PlayerName = host_player_name.text
	player_data.SelectedCharacter = GameState.selected_character
	
	rpc_add_or_update_player_data(var_to_str(player_data))
	
	map_selector.disabled = false
	start_game.disabled = false	
	
	enet_peer.peer_connected.connect(
		func(peer_id):
			await get_tree().create_timer(1).timeout			
			rpc_emmit_map_selected.rpc_id(peer_id, selected_map_index)

			var existing_players_serialized_data = var_to_str(GameState.players_data)
			rpc_player_registered.rpc_id(peer_id, existing_players_serialized_data)

			if GameState.is_game_started:
				rpc_game_already_started.rpc_id(peer_id)
				
	)
	enet_peer.peer_disconnected.connect(		
		func(peer_id):
			rpc_remove_player(peer_id)
			await get_tree().create_timer(1).timeout
			rpc_remove_player.rpc(peer_id)
	)
	
@rpc("any_peer")
func rpc_game_already_started():
	pass

@rpc("any_peer", "call_local")
func rpc_spawn_player(player_data_str: String):
	var player_data: PlayerData = str_to_var(player_data_str)
	SpawnPlayer.emit(player_data)
		
	
func _on_join_button_pressed():
	enet_peer.create_client(join_ip_address.text, int(join_port_number.text))
	multiplayer.multiplayer_peer = enet_peer
		
		
	multiplayer.connected_to_server.connect(
		func():
			var player_data: PlayerData = PlayerData.new()
			player_data.PeerId = multiplayer.get_unique_id()
			player_data.PlayerName = join_player_name.text
			player_data.SelectedCharacter = GameState.selected_character
			
			rpc_add_or_update_player_data.rpc(var_to_str(player_data))
			
			ServerConnected.emit()
	)
	
	multiplayer.server_disconnected.connect(
		func():
			players_list.clear()
			ServerDisconnected.emit()
	)
	
@rpc("any_peer")
func rpc_player_registered(existing_players_str:String):
	print("rpc_player_registered")

	rpc_add_existing_players(existing_players_str)

	var player_data: PlayerData = PlayerData.new()
	player_data.PeerId = multiplayer.get_unique_id()
	player_data.PlayerName = join_player_name.text
	player_data.SelectedCharacter = GameState.selected_character	
	
	rpc_add_or_update_player_data.rpc(var_to_str(player_data))
	
	
func rpc_add_existing_players(serialized_existing_players_data):
	print("rpc_add_existing_players")
	var existing_players_data:Array[PlayerData] = str_to_var(serialized_existing_players_data)	
	for existing_player_data in existing_players_data:	
		rpc_add_or_update_player_data(var_to_str(existing_player_data))


@rpc("any_peer")
func rpc_add_or_update_player_data(player_data_str: String):		
	print("rpc_add_or_update_player_data")
	var new_player_data:PlayerData = str_to_var(player_data_str)
	
	var found_player:bool = false
	
	for saved_player_data in GameState.players_data:
		if new_player_data.PeerId == saved_player_data.PeerId:
			GameState.update_player_data(new_player_data)
			found_player = true
			AddedPlayer.emit(new_player_data)
			
	if not found_player:
		GameState.players_data.push_back(new_player_data)

	players_list.clear()
			
	for saved_player_data in GameState.players_data:
		players_list.add_item(saved_player_data.PlayerName)
		
	
@rpc("any_peer")
func rpc_remove_player(peer_id) -> int:
	print("rpc_remove_player", peer_id)
	var found_player_index = GameState.get_player_index(peer_id)
	
	if(found_player_index > -1):
		GameState.players_data.remove_at(found_player_index)
		players_list.remove_item(found_player_index)	
	
	RemovedPlayer.emit(peer_id)	
	
	return found_player_index
	
@rpc("any_peer")
func rpc_emmit_map_selected(map_scene_index: int):	
	print("rpc_emmit_map_selected", map_scene_index)
	selected_map_index = map_scene_index
	map_selector.select(map_scene_index)
	
	if(map_scenes.size() > 0):
		MapSelected.emit(map_scenes[map_scene_index])		
	else:	
		ClearMap.emit()		
		
@rpc("any_peer","call_local")
func rpc_emmit_start_game():
	GameState.is_game_started = true
	StartGame.emit(map_scenes[selected_map_index], GameState.players_data)


func _on_select_map_input_item_selected(index):	
	selected_map_index = index
	MapSelected.emit(map_scenes[index])	
	rpc_emmit_map_selected.rpc(index)	
	
func _on_item_list_property_list_changed():
	print("_on_item_list_property_list_changed")


func _on_start_game_button_pressed():	
	rpc_emmit_start_game.rpc()
	
func setup_upnp():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discovery Failed")

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway() , "UPNP Invalid Gateway")
	
	var map_result = upnp.add_port_mapping(int(host_port_number.text))
	
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed")

	print("Successfully Join Address ")	
	
	host_external_ip_address.text = upnp.query_external_address()

func _on_u_pn_p_button_pressed():
	setup_upnp()


func _on_chat_send_message(messageTest: String):
	print("Send Message", messageTest)
	
	var remote_sender_id = multiplayer.get_remote_sender_id()
	var player_index = GameState.get_player_index(remote_sender_id)
	
	if player_index == -1:
		return

	var message: Message = Message.new()
	message.PeerId = remote_sender_id	
	message.PlayerName = GameState.players_data[player_index].PlayerName
	message.MessageText = messageTest
	
	GameState.allChatMessages.push_back(message)
	
	chat.RenderMessages(GameState.allChatMessages)
	
	
	
