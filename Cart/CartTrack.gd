extends PathFollow3D

@export var completeTime = 500

func _ready() -> void:
	create_tween().tween_property(self, "progress_ratio",1 ,completeTime)
