extends Node3D
class_name Map

@onready var Players = $Players

func add_player(player: Player):
	Players.add_child(player)
	
func add_players(players):
	for player in players:
		Players.add_child(player)

func get_players():
	return Players.get_children()
