extends RigidBody2D
@export_group("parametrs")
@export var elite:bool=false
@export_range(0,99999999) var dif:float=0
@export var run_speed:float=30.0
@export_range(1,999999999) var life_points_from:float=1.0
@export_range(1,999999999) var life_points_to:float=3.0
@export_range(1,999999999) var defence_from:float=0.5
@export_range(1,999999999) var defence_to:float=1.0
@export_group("drop")
@export var aditional_drop:PackedScene
@export_range(-999999999,999999999) var exp_from=4
@export_range(-999999999,999999999) var exp_to=10
@export_range(-999999999,999999999) var mny_from=2
@export_range(-999999999,999999999) var mny_to=6
@export_group("attack")
@export var attack_range:float=20
@export_range(1,999999999) var damage_from:float=1.0
@export_range(1,999999999) var damage_to:float=2.0
@export var pos_from:float=-10
@export var pos_to:float=10
@export_range(-180,180) var angle_from:float=-45
@export_range(-180,180) var angle_to:float=45
@onready var at=$at
@onready var hb=$hurt_box
# Called when the node enters the scene tree for the first time.

func _ready():
	hb.monitorable=true
	hb.monitoring=true
	$sp.material.set_deferred("shader_parameter/line_thickness",1.2*int(elite))
	var life_points=0
	var damage=0
	var def=0
	if !elite:
		life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)
		damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)
		def=fnc._with_dific(randf_range(defence_from,defence_to),dif)
	else:
		life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)*1.5
		damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)*1.5
		def=fnc._with_dific(randf_range(defence_from,defence_to),dif)*1.25
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	$hirtbox.damage=damage
	hb.s_m_d(def)
	hb.set_def(def)
	at.active=true
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
	$get_hero_body/c.polygon=pol

func get_input(target):
	return (target-global_position).normalized()

func _draw():
	draw_arc(Vector2.ZERO,attack_range,deg_to_rad($hirtbox.rotation_degrees+angle_to),deg_to_rad($hirtbox.rotation_degrees+angle_from),30,Color(1,0,0,0.5),2,true)

func _process(_delta):
	queue_redraw()
	_upd_anim_params()

var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=mvd
var vec:Vector2=Vector2.ZERO
var die:bool=false
var attak:bool=false
@onready var hero = fnc.get_hero()
func _physics_process(_delta):
	if die==false:
		mvd=get_input(hero.global_position)
		if mvd!=Vector2.ZERO:
			last_mvd=mvd
		attak=bs!=[]
		if attak==false:
			vec=mvd*run_speed
			$hirtbox.rotation_degrees=fnc.angle(last_mvd)
			$get_hero_body.rotation_degrees=$hirtbox.rotation_degrees
		else:
			vec=Vector2.ZERO
		set_linear_velocity(vec)
		
	else:
		at["parameters/conditions/death"]=true
	#print(state)
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
	if mny_from!=mny_to and exp_from!=exp_to:
		var v=preload("res://mats/ingame_value/value.tscn").instantiate()
		v.type=0#randi_range(0,1)
		if v.type==0:
			v.value=fnc._with_dific(randi_range(clamp(mny_from,0,999999999),clamp(mny_to,0,999999999)),dif)
		else:
			v.value=fnc._with_dific(randi_range(clamp(exp_from,0,999999999),clamp(exp_to,0,999999999)),dif)
		get_parent().add_child.call_deferred(v)
		v.global_position=global_position
	queue_free()

	
func _on_hurt_box_no_he():
	set_linear_velocity(Vector2.ZERO)
	die=true
	

var bs=[]
func _on_get_hero_body_body_entered(b):
	if b!=self and b.is_in_group("border")==false:
		bs.append(b)


func _on_get_hero_body_body_exited(b):
	if b!=self and b.is_in_group("border")==false:
		bs.remove_at(fnc.i_search(bs,b))
