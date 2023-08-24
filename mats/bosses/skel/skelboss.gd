extends RigidBody2D
@export_group("parametrs")
@export_range(0,100) var dif:float=0
@export var run_speed:float=30.0
@export var roll_speed:float=200.0
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
@export_group("rollatt")
@export_range(1,99999) var rollat_rast:float=100
@export_range(1,99999) var rollat_range:float=40
@export_range(1,999999999) var r_damage_from:float=1.0
@export_range(1,999999999) var r_damage_to:float=2.0
@export var r_pos_from:float=-10
@export var r_pos_to:float=10
@export_range(-180,180) var r_angle_from:float=-45
@export_range(-180,180) var r_angle_to:float=45
@export_group("summon")
@export_group("summon")
@export_enum("skel_wall","skel_circle")var summon_type:int=0
@export_range(1,99999) var spwn_range_from:int=25
@export_range(1,99999) var spwn_range_to:int=50
@export_subgroup("skel_wall")
@export_range(1,99999) var wskel_amout_from:int=3
@export_range(1,99999) var wskel_amout_to:int=8
@export_subgroup("skel_circle")
@export_range(1,99999) var cskel_amout_from:int=4
@export_range(1,99999) var cskel_amout_to:int=6
@onready var at=$at
@onready var hb=$hurt_box
# Called when the node enters the scene tree for the first time.

var summon_stages=[]
var spwn_skel_lvl=2
var max_summon_points=2
var current_summon_points=max_summon_points
signal dead
func _ready():
	connect("dead",Callable(get_tree().current_scene,"boss_die"))
	hb.monitorable=true
	hb.monitoring=true
	var life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	for e in range(max_summon_points):
		summon_stages.append(hb.m_he*e*0.5+(hb.m_he/max_summon_points/2))
	var damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)
	$hirtbox.damage=damage
	var damage1=fnc._with_dific(randf_range(r_damage_from,r_damage_to),dif)
	$ra_hirtbox.damage=damage1
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
	pol=PackedVector2Array([])
	tang=abs(r_angle_from)+abs(r_angle_to)
	ang=tang/dots
	if r_pos_from==r_pos_to and r_pos_to==0:
		pol.append(Vector2.ZERO)
	else:
		pol.append(Vector2(0,r_pos_to))
		pol.append(Vector2(0,r_pos_from))
	for e in range(dots+1):
		pol.append(fnc.move(e*ang+r_angle_from)*rollat_range)
	$ra_hirtbox/col.polygon=pol
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
var max_roll_points:int=1
var current_roll_points=max_roll_points
@onready var hero = fnc.get_hero()
var rolling=false
var timer=0
var roll_timer=0.4
var summon:bool=false
var attacking=false
var summoning=false
func _process(_delta):
	queue_redraw()
	_upd_anim_params()
	if die==false:
		if hero.die!=true and summoning==false:
			mvd=get_input(hero.global_position)
		else:
			mvd=Vector2.ZERO
		attak=bs!=[] and attacking==false and hero.die==false
		summon=len(summon_stages)!=0 and summon_stages[len(summon_stages)-1]>hb.he and hero.die==false
		#print(summon_stages[len(summon_stages)-1]," ",hb.he)
		if summon and summoning==false:
			summoning=true
			summon_stages.remove_at(len(summon_stages)-1)
			vec=Vector2.ZERO
		if attak:
			attacking=true
			vec=Vector2.ZERO
			#_freeze()
		var hero_rast=fnc._sqrt(hero.global_position-global_position) 
		var roll=attak==false and attacking==false and hero_rast<=rollat_rast and rolling==false and wait_roll==false and int(current_roll_points)>0
		if attak==false and roll==false and rolling==false and wait_roll==false and attacking==false:
			current_roll_points=clamp(current_roll_points+_delta*(1/add_roll_point_time),0,max_roll_points)
			if mvd!=Vector2.ZERO:
				last_mvd=mvd
			vec=mvd*run_speed
			$hirtbox.rotation_degrees=fnc.angle(last_mvd)
			$get_hero_area/c.rotation_degrees=$hirtbox.rotation_degrees
			$ra_hirtbox.rotation_degrees=$get_hero_area/c.rotation_degrees
		if roll and int(current_roll_points)>0 and rolling==false and wait_roll==false:
			freezed_mvd=last_mvd
			current_roll_points-=1
			wait_roll=true
		set_linear_velocity(vec)
	else:
		at["parameters/conditions/death"]=true
	#print(state)
var wait_roll=false
func set_roll(_t:bool):
	rolling=_t
	if _t==true:
		vec=freezed_mvd*roll_speed
	else:
		vec=Vector2.ZERO
	wait_roll=false
func getout_attack():
	attacking=false
	#_unfreeze()
func _upd_anim_params():
	$pb.value=hb.he
	$pb.max_value=hb.m_he
	at["parameters/conditions/idle"]=mvd==Vector2.ZERO and die==false
	at["parameters/conditions/run"]=mvd!=Vector2.ZERO and die==false
	at["parameters/conditions/attack1"]=attacking==true and (rolling==false or wait_roll==false) and die==false
	at["parameters/conditions/rollatt"]=(rolling or wait_roll) and attacking==false and die==false
	at["parameters/conditions/summon"]=summoning and (rolling==false or wait_roll==false) and attacking==false and die==false
	at["parameters/conditions/death"]=die
	at["parameters/run/blend_position"]=last_mvd
	at["parameters/idle/blend_position"]=last_mvd
	if !attacking:
		at["parameters/attack1/blend_position"]=last_mvd
	at["parameters/summon/blend_position"]=last_mvd
	at["parameters/rollatt/blend_position"]=last_mvd
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
	die=true

var bs=[]
func _on_body_entered(b):
	if b!=self and b.is_in_group("border")==false:
		bs.append(b)


func _on_body_exited(b):
	if b!=self and b.is_in_group("border")==false:
		bs.remove_at(fnc.i_search(bs,b))

func _summon(type:int=1,difficulty:float=spwn_skel_lvl):
	var amout=0
	var spwn_ang=0
	var ang1
	if type==0:
		amout=5-1#randi_range(wskel_amout_from,wskel_amout_to)-1
		spwn_ang=60
		ang1=spwn_ang/float(amout)
		for e in range(amout+1):
			var ang=fnc.angle(mvd)-spwn_ang/2
			var rast=randi_range(spwn_range_from,spwn_range_to)
			var pos=fnc.move(ang+e*ang1)*rast+global_position
			var en=preload("res://mats/enemys/e1/enemy1.tscn").instantiate()
			en.load_scene=preload("res://mats/enemys/e1/enemy1.tscn")
			en.scene_params={
				"global_position":pos,
				"dif":dif+0.5
			}
			en.global_position=pos
			get_parent().add_child.call_deferred(en)
	else:
		amout=randi_range(cskel_amout_from,cskel_amout_to)-1
		spwn_ang=360
		ang1=spwn_ang/float(amout)
		for e in range(amout):
			var ang=fnc.angle(mvd)-spwn_ang/2
			var rast=randi_range(spwn_range_from,spwn_range_to)
			var pos=fnc.move(ang+e*ang1)*rast+global_position
			var en=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
			var ens=[
					"res://mats/enemys/e1/enemy1.tscn",
					"res://mats/enemys/e2/enemy.tscn"
					]
			ens.shuffle()
			en.load_scene=load(ens[0])
			en.scene_params={
				"global_position":pos,
				"dif":dif+0.5
			}
			en.global_position=pos
			get_parent().add_child.call_deferred(en)
	summoning=false
			
