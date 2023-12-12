extends "res://mats/contents/damage/mele/damage.gd"
var start_pos:Vector2=Vector2.ZERO
var speed:float=100
var mvd:Vector2=Vector2.ZERO
var sqrt=200


func past_ready():
	drawing=false
	global_position=start_pos
	mvd=fnc.move(global_rotation_degrees)
	$p.emitting=true
	drawing=false
func delete():
	queue_free()

func past_proc(delta):
	position+=mvd*speed*delta
	if fnc._sqrt(position-start_pos)>sqrt:
		delete()

