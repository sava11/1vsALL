extends Area2D
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0
@export_range(0,99999) var speed:float=100
var max_count_through_enemy:int=1

var start_pos:Vector2=Vector2.ZERO
var mvd:Vector2=Vector2.ZERO
var sqrt=0
var count_through_enemy:int=0

func _ready():
	global_position=start_pos
	mvd=fnc.move(rotation_degrees)
	
func delete():
	queue_free()

func _physics_process(_delta):
	position+=mvd*speed*_delta
	if fnc._sqrt(position-start_pos)>sqrt:
		delete()
	rotation_degrees+=_delta*360*3


func _on_body_entered(body):
	count_through_enemy+=1
	if count_through_enemy>=max_count_through_enemy:
		delete()
