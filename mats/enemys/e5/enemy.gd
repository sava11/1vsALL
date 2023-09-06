extends RigidBody2D
@export_group("parametrs")
@export var elite:bool=false
@export_range(0,100) var dif:float=0
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
@export_subgroup("damage")
@export_range(1,999999999) var damage_from:float=1.0
@export_range(1,999999999) var damage_to:float=2.0
@export_subgroup("crit_damage")
@export_range(1,999999999) var crit_damage_from:float=1.0
@export_range(1,999999999) var crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var crit_chance_from:float=0
@export_range(0.0,1.0) var crit_chance_to:float=0
@onready var at=$at
@onready var hb=$hurt_box
var cur_dmg:float=0
var cur_crit:float=0
var cur_crit_chance:float=0
# Called when the node enters the scene tree for the first time.

func _ready():
	$sp.use_parent_material=false
	material=null
	hb.monitorable=true
	hb.monitoring=true
	$sp.material.set_deferred("shader_parameter/line_thickness",1.2*int(elite))
	var life_points=0
	var damage=0
	var def=0
	if !elite:
		life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)
		cur_dmg=fnc._with_dific(randf_range(damage_from,damage_to),dif)
		cur_crit=fnc._with_dific(randf_range(crit_damage_from,crit_damage_to),dif)
		cur_crit_chance=fnc._with_dific(randf_range(crit_chance_from,crit_chance_to),dif)
		def=fnc._with_dific(randf_range(defence_from,defence_to),dif)
	else:
		life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)*1.2
		cur_dmg=fnc._with_dific(randf_range(damage_from,damage_to),dif)*1.3
		cur_crit=fnc._with_dific(randf_range(crit_damage_from,crit_damage_to),dif)*1.5
		cur_crit_chance=fnc._with_dific(randf_range(crit_chance_from,crit_chance_to),dif)*1.2
		def=fnc._with_dific(randf_range(defence_from,defence_to),dif)*1.4
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	hb.s_m_d(def)
	hb.set_def(def)
	at.active=true
	at["parameters/conditions/death"]=false
	#hero detect нужно!

func get_input(target):
	return (target-global_position).normalized()
var target_pos:Vector2=Vector2.ZERO
func _draw():
	if at["parameters/conditions/attack1"]==true:
		var count=8
		var ang=360.0/float(count)
		for e in range(count):
			draw_line(Vector2.ZERO,fnc.move(e*ang+fnc.angle(target_pos-global_position))*attack_range,Color(1.0,0,0,0.2),4,true)
	pass
	#draw_arc(Vector2.ZERO,attack_range,,30,Color(1,0,0,0.5),2,true)

func _process(_delta):
	queue_redraw()
	_upd_anim_params()

var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=mvd
var vec:Vector2=Vector2.ZERO
var die:bool=false
var attak:bool=false
var attacking:bool=false
var attack_wait_time=3
var attack_wait_timer:float=0
var walk_back:bool=false
var tped:bool=false
var teleporting:bool=false
@onready var hero = fnc.get_hero()
func _physics_process(_delta):
	if die==false:
		mvd=get_input(hero.global_position)
		walk_back=fnc._sqrt(hero.global_position-global_position)<attack_range/2
		if mvd!=Vector2.ZERO:
			last_mvd=mvd
		attak=!attacking and !teleporting and !walk_back and attack_wait_timer>=attack_wait_time and fnc._sqrt(hero.global_position-global_position)<=attack_range

		if attak==true and !attacking and !teleporting:
			attacking=true
			attack_wait_timer=0
			vec=Vector2.ZERO
		if !tped and hb.he<hb.m_he:
			tped=true
			teleporting=true
			walk_back=false
			$at.active=false
			$ap.play("teleporting")
			vec=Vector2.ZERO
		if attak==false and !attacking and !walk_back and !teleporting :
			target_pos=hero.global_position
			attack_wait_timer+=_delta
			vec=mvd*run_speed
		if walk_back and !attacking  and !teleporting:
			attak=false
			attack_wait_timer+=_delta
			vec=fnc.move(fnc.angle(get_input(hero.global_position))-180)*run_speed

		set_linear_velocity(vec)
		
	else:
		at["parameters/conditions/death"]=true
func out_of_attack():attacking=false
func out_of_teleport():
	$at.active=true
	teleporting=false
func teleport():
	
	global_position=get_tree().current_scene.get_rand_pos()
func summon_arrow():
	var count=8
	var ang=360.0/float(count)
	for e in range(count):
		var s=preload("res://mats/enemys/e5/arrow.tscn").instantiate()
		s.speed=200
		s.global_position=global_position
		s.global_rotation_degrees=ang*e+fnc.angle(target_pos-global_position)
		s.start_pos=global_position
		#s.get_node("s").position.y-=10
		s.damage=cur_dmg
		s.crit_chance=cur_crit_chance
		s.crit_damage=cur_crit
		s.sqrt=attack_range
		get_tree().current_scene.ememys_path.add_child(s)

func _upd_anim_params():
	at["parameters/conditions/idle"]=mvd==Vector2.ZERO and die==false
	at["parameters/conditions/run"]=mvd!=Vector2.ZERO and die==false
	at["parameters/conditions/attack1"]=attacking and !walk_back and die==false
	at["parameters/conditions/death"]=die
	at["parameters/run/blend_position"]=last_mvd
	at["parameters/idle/blend_position"]=last_mvd
	if !attacking and !attak:
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

func aiming():
	var e=preload("res://mats/font/crit.tscn").instantiate()
	e.hide()
	e.texture=load(gm.images.icons.other.aim)
	e.global_position=global_position+Vector2(-e.size.x/2,-36)
	get_tree().current_scene.ememys_path.add_child(e)
	
func _on_hurt_box_no_he():
	set_linear_velocity(Vector2.ZERO)
	die=true
	
