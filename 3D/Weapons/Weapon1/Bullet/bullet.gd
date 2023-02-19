extends RigidBody3D
class_name Bullet

signal HitPlayer(peer_id: int)

func _on_body_entered(body):
	if body is Player3D:
		print("Player3D")
		var current_health = body.health_bar.get_health()
		var new_health = current_health - 1
				
		var player_data: PlayerData = GameState.get_player_data(body.name.to_int())
		player_data.Health = new_health
				
		HitPlayer.emit(player_data)
	

