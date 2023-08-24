extends RigidBody2D
@export_group("parametrs")
@export_range(0,100) var dif:float=0
@export var run_speed:float=30.0
@export_range(0.001,99999) var add_roll_point_time:float=5.0
@export_range(1,999999999) var life_points_from:float=6.0
@export_range(1,999999999) var life_points_to:float=8.0
@export_range(1,999999999) var defence_from:float=3.0
@export_range(1,999999999) var defence_to:float=5.0
@export_group("drop")
@export var aditional_drop:PackedScene
@export_range(0,999999999) var exp_from=4
@export_range(0,999999999) var exp_to=10
@export_range(0,999999999) var mny_from=2
@export_range(0,999999999) var mny_to=6
@export_group("attack")
@export var attack_range:float=25
@export_range(1,999999999) var damage_from:float=4.0
@export_range(1,999999999) var damage_to:float=8.0
@export var pos_from:float=-10
@export var pos_to:float=10
@export_range(-180,180) var angle_from:float=-25
@export_range(-180,180) var angle_to:float=25
@export_group("healself")
@export_range(0.01,100) var point_per_sec:float=1
@onready var at=$at
@onready var hb=$hurt_box
# Called when the node enters the scene tree for the first time.

var heal_stages=[]
var heal_points_per_sec=0
var spwn_skel_lvl=2
var max_heal_points=2
var current_heal_points=max_heal_points
signal dead
func _ready():
	get_tree().current_scene.summon(15)
	connect("dead",Callable(get_tree().current_scene,"boss_die"))
	hb.monitorable=true
	hb.monitoring=true
	var life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	for e in range(max_heal_points):
		heal_stages.append(hb.m_he*e*0.5+(hb.m_he/max_heal_points/3))
	heal_points_per_sec=fnc._with_dific(point_per_sec,dif)
	var damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)
	$hirtbox.damage=damage
	var def=fnc._with_dific(randf_range(defence_from,defence_to),dif)
	hb.s_m_d(def)
	hb.set_def(def)
	at["parameters/conditions/death"]=false
	at.active=true
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
	$get_hero_area/c.polygon=pol
func get_input(target):
	return (target-global_position).normalized()

func _draw():
	draw_arc(Vector2.ZERO,attack_range,deg_to_rad($hirtbox.rotation_degrees+angle_to),deg_to_rad($hirtbox.rotation_degrees+angle_from),30,Color(1,0,0,0.5),2,true)

var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=mvd
var vec:Vector2=Vector2.ZERO
var freezed_mvd:Vector2=mvd
var die:bool=false
var attak:bool=false
@onready var hero = fnc.get_hero()
var heal:bool=false
var attacking=false
var healing:bool=false
@onready var healing_timer=snapped($ap.get_animation("heal_down").length,0.1)
var heal_time=0
@onready var attak_timer=snapped($ap.get_animation("attack1_down").length,0.1)
var attak_time=0
func _process(_delta):
	queue_redraw()
	_upd_anim_params()
	if die==false:
		if hero.die!=true and healing==false:
			mvd=get_input(hero.global_position)
		else:
			mvd=Vector2.ZERO
		heal=len(heal_stages)!=0 and heal_stages[len(heal_stages)-1]>hb.he and hero.die==false
		attak=bs!=[] and attacking==false and heal==false and healing==false and heal==false and hero.die==false
		#print(summon_stages[len(summon_stages)-1]," ",hb.he)
		if heal and healing==false:
			heal_time=0
			healing=true
			get_tree().current_scene.summon(20)
			heal_stages.remove_at(len(heal_stages)-1)
			vec=Vector2.ZERO
		if healing :
			attacking=false
			heal_time+=_delta
			if heal_time>=healing_timer:
				healing=false
			else:
				hb.set_he(hb.he+heal_points_per_sec*_delta)
		if attak and !healing and !heal:
			attacking=true
			vec=Vector2.ZERO
		if attacking:
			vec=Vector2.ZERO
			attak_time+=_delta
			if attak_time>=attak_timer:
				attacking=false
				attak_time=0
		var hero_rast=fnc._sqrt(hero.global_position-global_position)
		if !attak and !attacking and !heal and !healing:
			if mvd!=Vector2.ZERO:
				last_mvd=mvd
			vec=mvd*run_speed
			$hirtbox.rotation_degrees=fnc.angle(last_mvd)
			$get_hero_area/c.rotation_degrees=$hirtbox.rotation_degrees
		set_linear_velocity(vec)
	else:
		at["parameters/conditions/death"]=true
	#print(state)
func getout_attack():
	attacking=false
	#_unfreeze()
func _upd_anim_params():
	$pb.value=hb.he
	$pb.max_value=hb.m_he
	at["parameters/conditions/idle"]=mvd==Vector2.ZERO and !healing and !attacking and die==false
	at["parameters/conditions/run"]=mvd!=Vector2.ZERO and attacking==false and die==false and healing==false
	at["parameters/conditions/attack1"]=attacking==true and die==false and !healing
	at["parameters/conditions/healing"]=healing and !attacking and die==false
	at["parameters/conditions/death"]=die
	
	at["parameters/run/blend_position"]=last_mvd
	at["parameters/idle/blend_position"]=last_mvd
	at["parameters/attack1/blend_position"]=last_mvd
	at["parameters/heal/blend_position"]=last_mvd
	at["parameters/death/blend_position"]=last_mvd
func delete():
	if mny_from!=mny_to and exp_from!=exp_to:
		var v=preload("res://mats/ingame_value/value.tscn").instantiate()
		v.type=0#randi_range(0,1)
		if v.type==0:
			v.value=randi_range(mny_from,mny_to)
		else:
			v.value=randi_range(exp_from,exp_to)
		get_parent().add_child.call_deferred(v)
		v.global_position=global_position
	emit_signal("dead")
	queue_free()

func _freeze():
	vec=Vector2.ZERO
	set_linear_velocity(vec)
	set_deferred("freeze",true)
func _unfreeze():
	set_deferred("freeze",false)
	

func _on_hurt_box_no_he():
	_freeze()
	print("die")
	die=true

var bs=[]
func _on_body_entered(b):
	if b!=self and b.is_in_group("border")==false:
		bs.append(b)


func _on_body_exited(b):
	if b!=self and b.is_in_group("border")==false:
		bs.remove_at(fnc.i_search(bs,b))

func heal_(v:bool=true):
	healing=v
			
