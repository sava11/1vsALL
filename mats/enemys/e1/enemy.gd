class_name enemy extends RigidBody2D
@export_group("parametrs")
@export var attack_range:float=40
@export var run_speed:float=80.0
@export_range(1,999999999) var life_points:float=2.0
@export_group("attack")
@export_range(1,999999999) var damage:float=2.0
@export var pos_from:float=-10
@export var pos_to:float=10
@export_range(-180,180) var angle_from:float=-45
@export_range(-180,180) var angle_to:float=45
@onready var at=$at
@onready var hb=$hurt_box
var attak:bool=false
# Called when the node enters the scene tree for the first time.
func _ready():
	hb.monitorable=true
	hb.monitoring=true
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	$hirtbox.damage=damage
	#at.active=true
	at["parameters/conditions/death"]=false
	var pol=PackedVector2Array([])
	var tang=abs(angle_from)+abs(angle_to)
	var dots=6
	
	var ang=tang/dots
	if pos_from==pos_to and pos_to==0:
		pol.append(Vector2.ZERO)
	else:
		pol.append(Vector2(0,pos_to))
		pol.append(Vector2(0,pos_from))
	for e in range(dots+1):
		pol.append(fnc.move(e*ang+angle_from)*attack_range)
	$hirtbox/col.polygon=pol

#enum{idle,move,rolling,attak_fast,die}
#var state:int=0
func get_input(target):
	var ang=45
	return fnc.move(fnc.get_ang_move(fnc.angle(target-global_position)+180,ang)*ang)

func _draw():
	draw_arc(Vector2.ZERO,30.0,deg_to_rad($hirtbox.rotation_degrees+angle_to),deg_to_rad($hirtbox.rotation_degrees+angle_from),30,Color(1,0,0,0.5),2,true)

func _process(_delta):
	queue_redraw()
	_upd_anim_params()



var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=mvd
var freezed_mvd:Vector2=mvd
var vec=Vector2.ZERO
var die=false
@onready var hero=fnc.get_hero()
func _physics_process(_delta):
	if die==false:
		mvd=Vector2.ZERO#get_input(hero.global_position)
		if mvd!=Vector2.ZERO:
			last_mvd=mvd
		attak=false
		var nearest_hero_pos=hero.global_position-global_position
		if fnc.angle(nearest_hero_pos)>$hirtbox.rotation_degrees+angle_from and fnc.angle(nearest_hero_pos)<=$hirtbox.rotation_degrees+angle_to:
			attak=fnc._sqrt(nearest_hero_pos)<=attack_range

		vec=mvd*run_speed
		$hirtbox.rotation_degrees=fnc.angle(last_mvd)
		set_linear_velocity(vec)
	#print(state)
func _freeze():
	freeze=true
	set_linear_velocity(Vector2.ZERO)
func _unfreeze():
	#print("unfrezd")
	freeze=false
func _exit_from_anim():
	_unfreeze()
func _upd_anim_params():
	at["parameters/conditions/idle"]=mvd==Vector2.ZERO and die==false
	at["parameters/conditions/run"]=mvd!=Vector2.ZERO and die==false
	at["parameters/conditions/attack1"]=attak and die==false
	at["parameters/conditions/death"]=die
	at["parameters/run/blend_position"]=last_mvd
	at["parameters/idle/blend_position"]=last_mvd
	at["parameters/attack1/blend_position"]=last_mvd#-1+2*int(get_global_mouse_position().x>global_position.x)
	at["parameters/death/blend_position"]=last_mvd
func delete():
	queue_free()
func _on_hurt_box_no_he():
	die=true
