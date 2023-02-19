extends Node3D
class_name CharacterSelector

@export var character_scenes: Array[PackedScene]

@onready var characters_list: ItemList =  $CanvasLayer/CharacterSelecterUI/HBoxContainer/CharacterList/CharactersList
@onready var character_container: Node3D = $CharacterContainer

@export var lobby_scene: PackedScene

var selected_character: Character

signal CharacterSelected(character: Character)

func _ready():
	clear_selected_characters()
	characters_list.clear()
	
	var index = 0
	for character_scene in character_scenes:
		index +=1
		characters_list.add_item("Character: "+ str(index))
	
func clear_selected_characters():
	for character in character_container.get_children():
		character_container.remove_child(character)		

func _on_characters_list_item_selected(index):
	clear_selected_characters()
	
	selected_character = character_scenes[index].instantiate()
	
	character_container.add_child(selected_character)
	

func _on_select_character_pressed():
	var lobby_instance: Lobby = lobby_scene.instantiate()	
	
	var new_character_scene = PackedScene.new()
	new_character_scene.pack(selected_character)
	
	GameState.selected_character = new_character_scene
	
	var new_lobby_scene = PackedScene.new()
	new_lobby_scene.pack(lobby_instance)
	
	get_tree().change_scene_to_packed(new_lobby_scene)
	
	CharacterSelected.emit(selected_character)
