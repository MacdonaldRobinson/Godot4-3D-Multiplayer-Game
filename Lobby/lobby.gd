extends Node3D

@onready var map_container = $MapContainer
@onready var players_container = $PlayersContainer
@onready var lobby_manager_ui = $CanvasLayer/LobbyManagerUI
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func clear_map():
	for node in map_container.get_children():
		map_container.remove_child(node)

func _on_lobby_manager_ui_map_selected(scene: LobbyManagerUI.MapScene):
	clear_map()
		
	var map_scene_instance = scene.map_scene.instantiate()
	map_container.add_child(map_scene_instance)
	
	print("_on_lobby_manager_ui_map_selected", scene)


func _on_lobby_manager_ui_clear_map():
	print("_on_lobby_manager_ui_clear_map")
	clear_map()


func _on_lobby_manager_ui_added_player(scene: LobbyManagerUI.PlayerScene):
#	var player_scene_instance = scene.player_scene.instantiate()
#	player_scene_instance.name = scene.player_name
#	players_container.add_child(player_scene_instance)	
	
	print("_on_lobby_manager_ui_added_player", scene)
	

func _on_lobby_manager_ui_start_game():
	lobby_manager_ui.hide()


func _on_lobby_manager_ui_removed_player(peer_id):
	print("_on_lobby_manager_ui_removed_player", peer_id)
