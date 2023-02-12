extends Control
class_name LobbyManagerUI

class MapScene:
	var map_name: String
	var map_scene: PackedScene
	
class PlayerScene:
	var player_name: String
	var player_scene: PackedScene

@onready var host_port_number = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/VBoxContainer/MarginContainer2/MarginContainer/PortNumber/PortNumberInput
@onready var map_selector = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/VBoxContainer/MarginContainer2/MarginContainer/SelectMap/SelectMapInput
@onready var players_list = $MarginContainer/HBoxContainer/VBoxContainer/PlayersList
@onready var join_ip_address = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Join/VBoxContainer/MarginContainer2/MarginContainer/IPAddressFields/IPAddressInput
@onready var join_port_number = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Join/VBoxContainer/MarginContainer2/MarginContainer/JoinPortNumberFields/JoinPortNumberInput
@onready var host_external_ip_address = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/ExternalIP/ExternalIPInput
@onready var start_game = $MarginContainer/HBoxContainer/VBoxContainer3/Host_Join/VBoxContainer/Host/VBoxContainer/MarginContainer2/MarginContainer/HostButtonFields/StartGameButton

var map_scenes: Array[MapScene]
var players: Array[PlayerScene]

var enet_peer = ENetMultiplayerPeer.new()
const Player = preload("res://Characters/Player/player.tscn")

signal MapSelected(map_scene_path:MapScene)
signal ClearMap()
signal AddedPlayer(player_scene:PlayerScene)
signal StartGame()

func _ready():	
	var map_scene = MapScene.new()
	map_scene.map_name = "Map 1"
	map_scene.map_scene = preload("res://Maps/Map1/map_1.tscn")	
	
	map_scenes.push_back(map_scene)
	
	map_selector.add_item("Select A Map")
	for scene in map_scenes:
		map_selector.add_item(scene.map_name)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_host_button_pressed():
	enet_peer.create_server(int(host_port_number.text))
	multiplayer.multiplayer_peer = enet_peer
	
	add_player(multiplayer.get_unique_id())
	
	enet_peer.peer_connected.connect(add_player)
	
func _on_join_button_pressed():
	enet_peer.create_client(join_ip_address.text, int(join_port_number.text))
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	print("add_player", peer_id)
	var player_scene = PlayerScene.new()
	player_scene.player_name = str(peer_id)
	player_scene.player_scene = Player
		
	players.push_back(player_scene)
	players_list.add_item(player_scene.player_name)
	
	emit_signal("AddedPlayer", player_scene)
	

func _on_select_map_input_item_selected(index):
	print("_on_select_map_input_item_selected", index)
	print("_on_select_map_input_item_selected", map_scenes[index-1])
	
	if(map_scenes.size() > 0 and index > 0):
		emit_signal("MapSelected", map_scenes[index-1])
	else:	
		emit_signal("ClearMap")
		

func _on_item_list_property_list_changed():
	print("_on_item_list_property_list_changed")


func _on_start_game_button_pressed():
	emit_signal("StartGame")
