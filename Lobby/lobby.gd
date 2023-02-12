extends Node3D

@onready var map_container = $MapContainer
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

func _on_lobby_manager_ui_map_selected(map: Map):
	clear_map()
		
	map_container.add_child(map)
	
	print("_on_lobby_manager_ui_map_selected", map)


func _on_lobby_manager_ui_clear_map():
	print("_on_lobby_manager_ui_clear_map")
	clear_map()


func _on_lobby_manager_ui_added_player(player: Player):
	lobby_manager_ui.hide()
	var current_map:Map = map_container.get_child(0)
	
	if(current_map):
		current_map.add_player(player)
	
	print("_on_lobby_manager_ui_added_player", player)
	

func _on_lobby_manager_ui_start_game():
	lobby_manager_ui.hide()


func _on_lobby_manager_ui_removed_player(peer_id):
	print("_on_lobby_manager_ui_removed_player", peer_id)
