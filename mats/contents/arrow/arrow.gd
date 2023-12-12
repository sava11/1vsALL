extends "res://mats/contents/damage/mele/damage.gd"

var start_pos:Vector2=Vector2.ZERO
var speed:float=100
var mvd:Vector2=Vector2.ZERO
var sqrt=0

func past_ready():
	global_position=start_pos
	mvd=fnc.move(global_rotation_degrees+90)
func delete():
	queue_free()

func past_proc(_delta):
	position+=mvd*speed*_delta
	if fnc._sqrt(position-start_pos)>sqrt:
		delete()
