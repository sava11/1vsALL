extends Area2D
@export var damage:float=1.0
@export var scale_damage:float=1.0

func _on_Timer_timeout():
	queue_free()
