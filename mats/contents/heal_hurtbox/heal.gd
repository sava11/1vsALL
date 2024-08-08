extends Node
@export var active:bool=true
@export var healing:bool=false
@export var hurtbox_path:NodePath="../"
@export_range(0.01,100) var heal_per_sec:float=1
@export_range(0.001,100) var healing_timer=0.001
@onready var hurtbox=get_node(hurtbox_path)
signal healing_end
var heal_time:float=0
func _process(delta):
	if healing and active:
		heal_time+=delta
		if heal_time<healing_timer and hurtbox.he<hurtbox.m_he:
			hurtbox.set_he(hurtbox.he+heal_per_sec*delta)
		else:
			heal_time=0
			emit_signal("healing_end")
			healing=false
	else:
		heal_time=0
