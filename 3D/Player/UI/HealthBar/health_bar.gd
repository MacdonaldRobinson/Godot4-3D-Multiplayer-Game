extends Sprite3D
class_name HealthBar

@onready var progress_bar: ProgressBar = $SubViewportContainer/SubViewport/ProgressBar

func get_health()->int:
	return progress_bar.value

func set_health(new_value:int):
	progress_bar.value = new_value	
