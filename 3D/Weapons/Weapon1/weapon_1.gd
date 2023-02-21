extends Node3D

@onready var bullet_spawn_point: Node3D = $BulletsSpawnPoint

@export var bullet_scene: PackedScene

func _unhandled_input(event):
	if !is_multiplayer_authority():
		return

func _process(delta):
	if !is_multiplayer_authority():
		return
		
	if Input.is_action_just_pressed("fire"):	
		fire.rpc()

@rpc("any_peer","call_local")
func fire():
	var new_bullet:Bullet = bullet_scene.instantiate()
	new_bullet.top_level = true
	bullet_spawn_point.add_child(new_bullet)			
	
	var force: Vector3 = -new_bullet.transform.basis.z * 3000	
	new_bullet.apply_central_force(force)		
	
	new_bullet.HitPlayer.connect(
		func(new_player_data: PlayerData):
			update_player_data(new_player_data)
			#rpc_update_player_data.rpc(var_to_str(new_player_data))
	)
	
func update_player_data(new_player_data: PlayerData):
	print("Ran TEST")
	rpc_update_player_data.rpc(var_to_str(new_player_data))
	
@rpc("any_peer")
func rpc_update_player_data(new_player_data_str: String):
	var new_player_data: PlayerData = str_to_var(new_player_data_str)
	GameState.update_player_data(new_player_data)
	var state = GameState.get_player_data(new_player_data.PeerId)
	
	
	
