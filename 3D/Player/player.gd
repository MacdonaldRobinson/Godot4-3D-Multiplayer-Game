extends CharacterBody3D
class_name Player3D

const SPEED = 10.0
const JUMP_VELOCITY = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_spring_arm: SpringArm3D = $CameraSpringArm
@onready var camera: Camera3D = $CameraSpringArm/Camera3D
@onready var player_name_label: Label3D = $PlayerName
@onready var character_container: Node3D = $CharacterContainer
@onready var health_bar: HealthBar = $HealthBar
@onready var weapon_container: Node3D = $WeaponContainer

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():	
	player_name_label.text = name
		
	if not is_multiplayer_authority(): return	
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	

func update_from_player_data():
	var player_data: PlayerData = GameState.get_player_data(name.to_int())
	
	if player_data: 
		player_name_label.text = player_data.PlayerName
		health_bar.set_health(player_data.Health)	
		var character_instance: Character = player_data.SelectedCharacter.instantiate()		
		
		for child in character_container.get_children():
			if child.name == character_instance.name:
				child.collision_shape.reparent(self)	
				return				
		
		clear_character_container()
		
		character_container.add_child(character_instance)	
		
	
func clear_character_container():
	for child in character_container.get_children():
		character_container.remove_child(child)
	
func set_player_data(player_data: PlayerData):
	var player_index = GameState.get_player_index(player_data.PeerId)
	GameState.players_data[player_index] = player_data
	
func _unhandled_input(event):
	if not is_multiplayer_authority(): return
			
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		camera_spring_arm.rotate_x(-event.relative.y * 0.005)
		camera_spring_arm.rotation.x = clamp(camera_spring_arm.rotation.x, -PI/2, PI/2)
		weapon_container.rotation = camera_spring_arm.rotation

	if Input.is_action_just_pressed("toggle_mouse_capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	

func _physics_process(delta):
	update_from_player_data()
	
	if  not is_multiplayer_authority(): return
	
	camera.current = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	#input_dir = input_dir.rotated(-camera_spring_arm.rotation.y).normalized()	
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()	

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		

	move_and_slide()
