extends Node3D
class_name Character

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func get_collision_shape() -> CollisionShape3D:
	return collision_shape
