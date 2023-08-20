extends Area2D
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0

func _on_Timer_timeout():
	queue_free()
