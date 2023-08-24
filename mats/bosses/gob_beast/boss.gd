extends RigidBody2D
@export_group("parametrs")
@export_range(0,100) var dif:float=0
@export var run_speed:float=30.0
@export var streight:float=5
var streight_regen:float=0.5
@onready var cur_streight=streight
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
@export_subgroup("low range")
@export var attack_range:float=25
@export_range(1,999999999) var damage_from:float=4.0
@export_range(1,999999999) var damage_to:float=8.0
@export var pos_from:float=-10
@export var pos_to:float=10
@export_range(-180,180) var angle_from:float=-25
@export_range(-180,180) var angle_to:float=25
@export_subgroup("high range")
@export var fb_attack_range:float=25
@export_range(1,999999999) var fb_damage_from:float=4.0
@export_range(1,999999999) var fb_damage_to:float=8.0
@onready var at=$at
@onready var hb=$hurt_box
# Called when the node enters the scene tree for the first time.

signal dead
func _ready():
	#get_tree().current_scene.summon(15)
	connect("dead",Callable(get_tree().current_scene,"boss_die"))
	hb.monitorable=true
	hb.monitoring=true
	var life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)
	hb.s_m_h(life_points)
	hb.set_he(life_points)
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
	if attacking2:
		draw_line(Vector2.ZERO,hero.global_position-global_position,Color(1,0,0,1),4,true)
	
	draw_arc(Vector2.ZERO,attack_range,deg_to_rad($hirtbox.rotation_degrees+angle_to),deg_to_rad($hirtbox.rotation_degrees+angle_from),30,Color(1,0,0,0.5),2,true)

var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=mvd
var vec:Vector2=Vector2.ZERO
var freezed_mvd:Vector2=mvd
var die:bool=false
var attak:bool=false
var attacking:bool=false
var attak2:bool=false
var attacking2:bool=false
@onready var hero = fnc.get_hero()
@onready var attak_timer=snapped($ap.get_animation("attack1_down").length,0.1)
var attak_time=0
@onready var attak_timer2=snapped($ap.get_animation("attack2_down").length,0.1)
var attak_time2=0
var chance_to_attack2=0.15
var chance_time:float=0.5
var chance_timer:float=0
var moving:bool=false
func get_counts(v1:float,mod:float):
	var temp_value=v1
	var count=0
	while temp_value-mod>0:
		temp_value-=mod
		count+=1
	return count
func _process(_delta):
	queue_redraw()
	_upd_anim_params()
	if die==false and moving:
		if hero.die!=true :
			mvd=get_input(hero.global_position)
		else:
			mvd=Vector2.ZERO
		var hsqrt=fnc._sqrt(hero.global_position-global_position)
		attak2=false
		if hsqrt>(fb_attack_range-attack_range)/3 and hsqrt<fb_attack_range and !attacking2:
			chance_timer+=_delta
			if chance_timer>=chance_time:
				if fnc._with_chance(chance_to_attack2):
					attak2=!attacking2 and !hero.die and cur_streight-_streight_fb>0 
				chance_timer=0
		
		attak=bs!=[] and !attacking and !hero.die and !attak2 and !attacking2
		#print(summon_stages[len(summon_stages)-1]," ",hb.he)
		if attak and !attacking:
			attacking=true
			attacking2=false
			fb_counts=0
			vec=Vector2.ZERO
			cur_streight-=0.4#скорость траты силы на удар
		if attacking:
			vec=Vector2.ZERO
			attak_time+=_delta
			if attak_time>=attak_timer:
				attacking=false
				attak_time=0
		if attak2 and !attacking2:
			attacking2=true
			cur_max_fb_counts=gm.rnd.randi_range(1,get_counts(cur_streight,_streight_fb))
			vec=Vector2.ZERO
		if attacking2:
			vec=Vector2.ZERO
			attak_time2+=_delta
			if attak_time2>=attak_timer2*cur_max_fb_counts:
				attacking2=false
				attak_time2=0
		var hero_rast=fnc._sqrt(hero.global_position-global_position)
		if !attak and !attacking and !attak2 and !attacking2:
			if mvd!=Vector2.ZERO:
				last_mvd=mvd
			cur_streight-=0.1*_delta#скорость траты силы на бег
			vec=mvd*run_speed
			$hirtbox.rotation_degrees=fnc.angle(last_mvd)
			$get_hero_area/c.rotation_degrees=$hirtbox.rotation_degrees
		if cur_streight<=0:
			vec=Vector2.ZERO
			moving=false
		set_linear_velocity(vec)
	else:
		if die:
			at["parameters/conditions/death"]=true
		if !moving:
			mvd=Vector2.ZERO
			cur_streight=clamp(cur_streight+streight_regen*_delta,0,streight)
			if cur_streight==streight:
				moving=true
	#print(state)
func getout_attack():
	attacking=false
	#_unfreeze()
var fb_counts=0
var cur_max_fb_counts=3
var _streight_fb=0.8
func end_fireball_attack():
	if fb_counts<=cur_max_fb_counts:
		fb_counts+=1
		cur_streight-=_streight_fb#скорость траты силы на вызов огненного шара
	else:
		fb_counts=0
		attacking2=false
		print("exww")
func summon_fireball():
	var a=preload("res://mats/bosses/gob_beast/fireball.tscn").instantiate()
	a.speed=100
	var hrast=fnc._sqrt(fnc.get_hero().global_position-global_position)
	var targ=(fnc.get_hero().vec*(hrast/a.speed)+fnc.get_hero().global_position-global_position)
	a.position=global_position+targ.normalized()*10
	a.global_rotation_degrees=fnc.angle(targ)-90
	var damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)
	a.start_pos=global_position
	#a.get_node("s").position.y-=10
	a.damage=damage
	a.sqrt=fnc._sqrt((fnc.get_hero().global_position-global_position).normalized()*fb_attack_range)
	a.mvd=(targ).normalized()
	get_tree().current_scene.ememys_path.add_child(a)

func _upd_anim_params():
	$pb.value=hb.he
	$pb.max_value=hb.m_he
	$sth.value=cur_streight
	$sth.max_value=streight
	at["parameters/conditions/idle"]=mvd==Vector2.ZERO and !attacking and !attacking2 and die==false
	at["parameters/conditions/run"]=mvd!=Vector2.ZERO and !attacking and !attacking2 and die==false
	at["parameters/conditions/attack1"]=attacking==true and die==false 
	at["parameters/conditions/death"]=die
	at["parameters/conditions/attack2"]=(attacking2) and die==false 
	
	
	at["parameters/run/blend_position"]=last_mvd
	at["parameters/idle/blend_position"]=last_mvd
	if !attacking:
		at["parameters/attack1/blend_position"]=last_mvd
	if !attacking2:
		at["parameters/attack2/blend_position"]=last_mvd
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
