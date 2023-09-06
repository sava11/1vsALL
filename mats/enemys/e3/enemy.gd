extends RigidBody2D
@export_group("parametrs")
@export var elite:bool=false
@export_range(0,100) var dif:float=0
@export var run_speed:float=30.0
@export var fast_run_speed:float=50.0#
@export var jump_speed:float=70.0
@export_range(1,999999999) var life_points_from:float=1.0
@export_range(1,999999999) var life_points_to:float=3.0
@export_range(1,999999999) var defence_from:float=0.5
@export_range(1,999999999) var defence_to:float=1.0
@export_group("drop")
@export var aditional_drop:PackedScene
@export_range(0,999999999) var exp_from=4
@export_range(0,999999999) var exp_to=10
@export_range(0,999999999) var mny_from=2
@export_range(0,999999999) var mny_to=6
@export_group("axe attack")
@export var attack_range:float=35
@export var pos_from:float=0
@export var pos_to:float=0
@export_range(-180,180) var angle_from:float=-25
@export_range(-180,180) var angle_to:float=25
@export_subgroup("damage")
@export_range(1,999999999) var damage_from:float=1.0
@export_range(1,999999999) var damage_to:float=2.0
@export_subgroup("crit_damage")
@export_range(1,999999999) var crit_damage_from:float=1.0
@export_range(1,999999999) var crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var crit_chance_from:float=0.05
@export_range(0.0,1.0) var crit_chance_to:float=0.1
@export_group("jump attack")
@export var j_attack_range:float=150
@export_subgroup("damage")
@export_range(1,999999999) var j_damage_from:float=4.0
@export_range(1,999999999) var j_damage_to:float=6.0
@export_subgroup("crit_damage")
@export_range(1,999999999) var j_crit_damage_from:float=5.0
@export_range(1,999999999) var j_crit_damage_to:float=10.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var j_crit_chance_from:float=0.15
@export_range(0.0,1.0) var j_crit_chance_to:float=0.2
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
		life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)*1.2
		damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)*1.3
		def=fnc._with_dific(randf_range(defence_from,defence_to),dif)*1.4
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	hb.s_m_d(def)
	hb.set_def(def)
	$hirtbox.damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)
	$hirtbox.crit_damage=fnc._with_dific(randf_range(crit_damage_from,crit_damage_to),dif)
	$hirtbox.crit_chance=fnc._with_dific(randf_range(crit_chance_from,crit_chance_to),dif)
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
	$get_hero_body/c.polygon=pol
	$hirtbox/col.polygon=pol
	#hero detect нужно!

func get_input(target):
	return (target-global_position).normalized()

func _draw():
	draw_arc(Vector2.ZERO,attack_range,deg_to_rad($hirtbox.rotation_degrees+angle_to),deg_to_rad($hirtbox.rotation_degrees+angle_from),30,Color(1,0,0,0.5),2,true)
	pass
	#draw_arc(Vector2.ZERO,attack_range,,30,Color(1,0,0,0.5),2,true)

func _process(_delta):
	queue_redraw()
	_upd_anim_params()

var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=mvd
var vec:Vector2=Vector2.ZERO
var calculated_landing_pos:Vector2=Vector2.ZERO
var die:bool=false
var attak:bool=false
var attacking:bool=false
var not_move_time:float=3
var not_move_timer:float=0
var move_time:float=5
var move_timer:float=0
var moveing:bool=true
var jump:bool=false
var jumping:bool=false
var j_r:bool=false
var j_j:bool=false
var j_l:bool=false
@onready var hero = fnc.get_hero()
func _physics_process(_delta):
	if die==false:
		if moveing:
			move_timer+=_delta
			mvd=get_input(hero.global_position)
			if move_timer>move_time:
				moveing=false
				move_timer=0
		else:
			not_move_timer+=_delta
			mvd=Vector2.ZERO
			if not_move_timer>not_move_time:
				moveing=true
				not_move_timer=0
			vec=Vector2.ZERO
		var hsqrt=fnc._sqrt(hero.global_position-global_position)
		if mvd!=Vector2.ZERO:
			last_mvd=mvd
		
		if moveing :
			var get_back=hsqrt<attack_range/2 and !jump and !jumping
			attak=bs!=[] and !jump and !jumping and !attacking and !at["parameters/conditions/idle"] and fnc._sqrt(hero.global_position-global_position)<attack_range
		
			if !attak and !attacking:
				vec=mvd*run_speed
				$get_hero_body.rotation_degrees=fnc.angle(get_input(hero.global_position))
				$hirtbox.rotation_degrees=$get_hero_body.rotation_degrees
			if get_back:
				attak=false
				vec=fnc.move(fnc.angle(get_input(hero.global_position))-180)*run_speed*1.5
			if attak==true:
				attacking=true
				vec=Vector2.ZERO
			
					
		set_linear_velocity(vec)
		
	else:
		at["parameters/conditions/death"]=true

func out_of_attack():attacking=false


func _upd_anim_params():
	at["parameters/conditions/idle"]=mvd==Vector2.ZERO and die==false
	at["parameters/conditions/run"]=mvd!=Vector2.ZERO and die==false
	at["parameters/conditions/attack1"]=attacking and die==false
	at["parameters/conditions/death"]=die
	
	at["parameters/conditions/frun"]=j_r and (jumping or jump) and !j_j and !j_l
	at["parameters/conditions/jump"]=j_j and (jumping or jump) and !j_r and !j_l
	at["parameters/conditions/landing"]=j_l and (jumping or jump) and !j_r and !j_j
	
	at["parameters/run/blend_position"]=last_mvd
	at["parameters/idle/blend_position"]=last_mvd
	if !attacking:
		at["parameters/attack1/blend_position"]=last_mvd
	at["parameters/death/blend_position"]=last_mvd
	if !jumping:
		at["parameters/frun/blend_position"]=last_mvd
		at["parameters/jump/blend_position"]=last_mvd
		at["parameters/landing/blend_position"]=last_mvd
	
func aiming():
	var e=preload("res://mats/font/crit.tscn").instantiate()
	e.texture=load(gm.images.icons.other.aim)
	e.global_position=global_position+Vector2(-e.size.x/2,-36)
	get_tree().current_scene.ememys_path.add_child(e)

func delete():
	if mny_from!=mny_to and exp_from!=exp_to:
		var v=preload("res://mats/ingame_value/value.tscn").instantiate()
		v.type=0#randi_range(0,1)
		if v.type==0:
			v.value=fnc._with_dific(randi_range(mny_from,mny_to),dif)
		else:
			v.value=fnc._with_dific(randi_range(exp_from,exp_to),dif)
		get_parent().add_child.call_deferred(v)
		v.global_position=global_position
	queue_free()
func summon_hirt_area():
	var a=preload("res://mats/enemys/e3/custom_dmg_area.tscn").instantiate()
	a.think(10)
	a.collision_layer=2
	a.damage=fnc._with_dific(gm.rnd.randf_range(j_damage_from,j_damage_to),dif)
	a.crit_damage=fnc._with_dific(gm.rnd.randf_range(j_crit_damage_from,j_crit_damage_to),dif)
	a.crit_chance=fnc._with_dific(gm.rnd.randf_range(j_crit_chance_from,j_crit_chance_to),dif)
	a.global_position=calculated_landing_pos
	fnc.get_world_node().get_node("ent/enemys").add_child(a)
	
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
