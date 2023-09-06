extends Area2D
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0
@export var curve:Curve
var start_pos:Vector2=Vector2.ZERO
var speed:float=100
var acc:float=200
var mvd:Vector2=Vector2.ZERO
var target=null
var vec=Vector2.ZERO
func _ready():
	global_position=start_pos
	$p.emitting=true
func delete():
	queue_free()

func _physics_process(_delta):
	$p.modulate.a=curve.sample_baked($t.time_left/$t.wait_time)
	position+=vec.move_toward((target.global_position-global_position).normalized()*speed,acc*_delta)

func _on_t_timeout():
	delete()
