extends Node3D
class_name Map3D

var players_container: Node3D

func set_players_container(players_container: Node3D):
	self.players_container = players_container

func get_players_container() -> Node3D:
	return players_container;
