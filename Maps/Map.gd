extends Node3D
class_name Map

@onready var Players = $Players

func add_player(player: Player):
	Players.add_child(player)
