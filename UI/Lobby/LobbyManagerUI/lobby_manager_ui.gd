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
signal AddedPlayer(player:PlayerData)
signal RemovedPlayer(peer_id:int)
signal StartGame(players:Array[PlayerData])
signal UpdatedPlayerData(player_data: PlayerData)
signal ServerDisconnected()

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
	
	EmmitMapSelected(selected_map_index)
	
	var player_data: PlayerData = PlayerData.new()
	player_data.PeerId = host_peer_id
	player_data.PlayerName = host_player_name.text
	player_data.SelectedCharacter = GameState.selected_character
	
	add_player(player_data)
	
	map_selector.disabled = false
	start_game.disabled = false	
	
	enet_peer.peer_connected.connect(
		func(peer_id):
			await get_tree().create_timer(1).timeout			
			EmmitMapSelected.rpc(selected_map_index)
			
			var serilizedData = var_to_str(GameState.players_data)
			add_existing_players.rpc(serilizedData)
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
	
	multiplayer.connected_to_server.connect(
		func():
			var player_data: PlayerData = PlayerData.new()
			player_data.PeerId = multiplayer.get_unique_id()
			player_data.PlayerName = join_player_name.text
			player_data.SelectedCharacter = GameState.selected_character
			
			update_player_data.rpc(var_to_str(player_data))
	)
	
	multiplayer.server_disconnected.connect(
		func():
			players_list.clear()
			ServerDisconnected.emit()
	)
	
func update_player_list(player_data: PlayerData):
	var list_item_count = players_list.item_count
	var found_index = -1
	for index in list_item_count:
		var index_text = players_list.get_item_text(index)
		if index_text == str(player_data.PeerId):
			found_index = index
			
	if found_index == -1:
		players_list.add_item(player_data.PlayerName)
	else:
		players_list.set_item_text(found_index, player_data.PlayerName)

	
@rpc("any_peer")
func update_player_data(player_data_str:String):
	var player_data: PlayerData = str_to_var(player_data_str)
	GameState.update_player_data(player_data)	
	update_player_list(player_data)

	UpdatedPlayerData.emit(player_data)

	
@rpc
func add_existing_players(serialized_existing_players_data):
	var existing_players_data:Array[PlayerData] = str_to_var(serialized_existing_players_data)
	
	for existing_player_data in existing_players_data:	
		var found_player_index = GameState.get_player_index(existing_player_data.PeerId)
		if found_player_index == -1:
			add_player(existing_player_data)

func add_player(player_data: PlayerData):
		
	print("add_player", player_data)
	
	var existing_player_index = GameState.get_player_index(player_data.PeerId)
	
	if existing_player_index == -1:
		GameState.players_data.push_back(player_data)
		players_list.add_item(player_data.PlayerName)
		AddedPlayer.emit(player_data)		
	
@rpc
func remove_player(peer_id) -> int:
	print("remove_player", peer_id)
	var found_player_index = GameState.get_player_index(peer_id)
	
	if(found_player_index > -1):
		GameState.players_data.remove_at(found_player_index)
		players_list.remove_item(found_player_index)	
	
	RemovedPlayer.emit(peer_id)	
	
	return found_player_index
	
@rpc
func EmmitMapSelected(map_scene_index: int):	
	print("EmmitMapSelected", map_scene_index)
	map_selector.select(map_scene_index)
	
	if(map_scenes.size() > 0):
		MapSelected.emit(map_scenes[map_scene_index])		
	else:	
		ClearMap.emit()		
		
@rpc("call_local")
func EmmitStartGame():
	StartGame.emit(map_scenes[selected_map_index], GameState.players_data)


func _on_select_map_input_item_selected(index):	
	selected_map_index = index
	MapSelected.emit(map_scenes[index])	
	EmmitMapSelected.rpc(index)	
	
func _on_item_list_property_list_changed():
	print("_on_item_list_property_list_changed")


func _on_start_game_button_pressed():	
	EmmitStartGame.rpc()
	
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
	
	
	
