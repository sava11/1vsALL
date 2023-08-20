extends Area2D
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0
var start_pos:Vector2=Vector2.ZERO
var speed:float=100
var mvd:Vector2=Vector2.ZERO
var sqrt=0

func _ready():
	global_position=start_pos
func delete():
	queue_free()

func _physics_process(_delta):
	queue_redraw()
	position+=mvd*speed*_delta
	if fnc._sqrt(position-start_pos)>sqrt:
		delete()
