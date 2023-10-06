extends RigidBody2D
@export_range(1,99999) var speed:float=100
@export_range(1,99999) var acc_speed:float=100
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0
var vec:Vector2=Vector2.ZERO
@onready var target=fnc.get_hero()
# Called when the node enters the scene tree for the first time.
func _ready():
	$c.emitting=true
	$hirtbox.damage=damage
	$hirtbox.crit_damage=crit_damage
	$hirtbox.crit_chance=crit_chance
	pass # Replace with function body.


var last_vec:Vector2=Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	last_vec=vec
	var cur_sqrt=(vec-last_vec).normalized()
	vec=get_linear_velocity()
	vec=vec.move_toward((target.global_position-global_position).normalized()*speed,acc_speed*_delta)
	$c.gravity=cur_sqrt*98
	set_linear_velocity(vec)

func delete():
	queue_free()

func _on_del_area_body_entered(body):
	if body!=self:
		delete()
