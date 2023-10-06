extends RigidBody2D
@export_group("parametrs")
@export var elite:bool=false
@export_range(0,100) var dif:float=1
@export var run_speed:float=25.0
@export var save_sqrt:float=-1
#enum statuses{a,d,i,r,rb,wait_anim}
@export var statuses:Dictionary={
	"a":"attack",
	"d":"death",
	"i":"idle",
	"r":"run",
	"wait_anim":"",
	}
@export var attacks_chance_list={"attack":1.0}
@export_subgroup("life")
@export_range(1,999999999) var life_points_from:float=1.0
@export_range(1,999999999) var life_points_to:float=3.0
@export_subgroup("defence")
@export_range(1,999999999) var defence_from:float=0.5
@export_range(1,999999999) var defence_to:float=1.0
@export_group("drop")
@export var aditional_drop:PackedScene
@export_subgroup("exp")
@export_range(-999999999,999999999) var exp_from=4
@export_range(-999999999,999999999) var exp_to=10
@export_subgroup("money")
@export_range(-999999999,999999999) var mny_from=2
@export_range(-999999999,999999999) var mny_to=6
@export_group("attack1")
@export_range(0,99999) var attack1_time_period:float=2.0
@export var attack_range:float=30
@export_subgroup("damage")
@export_range(1,999999999) var damage_from:float=1.0
@export_range(1,999999999) var damage_to:float=2.0
@export var pos_from:float=-10
@export var pos_to:float=10
@export_range(-180,180) var angle_from:float=-45
@export_range(-180,180) var angle_to:float=45
@export_subgroup("crit_damage")
@export_range(1,999999999) var crit_damage_from:float=1.0
@export_range(1,999999999) var crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var crit_chance_from:float=0
@export_range(0.0,1.0) var crit_chance_to:float=0
@onready var hero=fnc.get_hero()
@onready var hb=$hurt_box
#@onready var at=$at
@onready var na=$na
enum custom_states{}
var attacks_times=[]
var cur_target_pos=Vector2.ZERO
#timers
var attacks_timer:float=0
var think_timer:float=0
var think_time:float=1

var target_position=Vector2.ZERO
var vec:Vector2=Vector2.ZERO
var last_mvd:Vector2=Vector2.ZERO
var state="i"
@onready var cur_anim=statuses[state]

func get_sqrt(obj):
	return fnc._sqrt(obj.global_position-global_position)
var last_anim:int=0
func set_anim(anim_name:String,to_target:Vector2=na.get_next_path_position(),oneshoot:bool=false,changeing_pos:bool=true):
	var tname=""
	var anim=get_ang_move(rad_to_deg((to_target-global_position).angle())+180,90)*int(changeing_pos)+last_anim*int(!changeing_pos)
	last_anim=anim
	if anim==0:
		tname="_right"
	elif anim==2:
		tname="_left"
	elif anim==1:
		tname="_down"
	elif anim==3:
		tname="_up"
	if oneshoot:
		if $sp.animation!=anim_name+tname:
			$sp.animation=anim_name+tname
			$ap.play(anim_name)
			anim_finish=false
			cur_anim=anim_name
	else:
		$sp.animation=anim_name+tname
		$ap.play(anim_name)
		cur_anim=anim_name
		anim_finish=false
func get_input(target):
	return (target-global_position).normalized()
func get_ang_move(angle:float,ex:float):
	var ang1=abs(ex)
	var le=int(360/ang1)
	var ang=int(abs(angle)+180+ang1/2)%360
	if ang>=0:for e in range(0,le):
		if ang>=e*ang1 and ang<(e+1)*ang1:
			return e
var anim_finish:bool=false
var can_attack:bool=false
func _ready():
	$ap.connect("animation_finished",Callable(self,"_on_ap_animation_finished"))
	if !$na.is_connected("velocity_computed",Callable(self,"move")):
		$na.connect("velocity_computed",Callable(self,"move"))
	for e in attacks_chance_list.keys():
		attacks_times.append(attacks_chance_list[e])
	$sp.material.set_deferred("shader_parameter/line_thickness",1.2*int(elite))
	hb.monitorable=true
	hb.monitoring=true
	
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
	hb.s_m_d(def)
	hb.set_def(def)
	$hirtbox.damage=damage
	set_att_zone()
func set_att_zone():
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

var current_action:int=0
func thinker():
	if think_timer>=think_time and current_action==0:
		think_timer=0
		current_action=fnc._with_chance_ulti(attacks_times)+1
func _draw():
	draw_arc(Vector2.ZERO,attack_range,deg_to_rad($hirtbox.rotation_degrees+angle_to),deg_to_rad($hirtbox.rotation_degrees+angle_from),30,Color(1,0,0,0.5),2,true)
func _process(_delta):
	
	$get_hero_body/r.global_rotation_degrees=0
	queue_redraw()
func _integrate_forces(st):
	vec=st.get_linear_velocity()
	
	pre_status()
	find_status(st.get_step())
	post_status()
	
	#set_anim()
func get_visual_contact_with(obj):
	return $get_hero_body/r.get_collider()==obj
func pre_status():
	$get_hero_body/r.target_position=hero.global_position-global_position
	can_attack=get_visual_contact_with(hero) and get_sqrt(hero)<=attack_range and get_sqrt(hero)>=save_sqrt
	
	$get_hero_body.rotation_degrees=fnc.angle(get_input(hero.global_position))
	$hirtbox.rotation_degrees=$get_hero_body.rotation_degrees
	pass
func timers(_delta):
	attacks_timer+=_delta
	think_timer+=_delta
func find_status(_delta:float):
	if state!="wait_anim" and state!="d":
		if !can_attack and get_sqrt(hero)>=save_sqrt:
			cur_target_pos=hero.global_position
			state="r"
		if get_visual_contact_with(hero) and get_sqrt(hero)<save_sqrt:
			cur_target_pos=global_position+(global_position-hero.global_position).normalized()*save_sqrt
			state="r"
		na.target_position=cur_target_pos
	if state=="wait_anim":
		if anim_finish:
			state="i"
			current_action=0
	if state=="a":
		attacks_timer=0
		vec=Vector2.ZERO
		set_anim(statuses[state],hero.global_position)
		target_position=hero.global_position
		state="wait_anim"
		na.set_velocity(vec)
	if state=="r":
		set_anim(statuses[state])
		timers(_delta)
		thinker()
		from_idle_or_run_to_do()
		var cvec=global_position.direction_to(na.get_next_path_position())*run_speed
		last_mvd=global_position.direction_to(na.get_next_path_position())
		na.set_velocity(cvec)
		if na.is_navigation_finished() and (get_sqrt(hero)>save_sqrt and get_sqrt(hero)<=attack_range):
			state="i"
			return
	if state=="i":
		if can_attack:
			set_anim(statuses[state],hero.global_position)
		else:
			set_anim(statuses[state])
		vec=Vector2.ZERO
		na.set_velocity(vec)
		timers(_delta)
		thinker()
		cur_target_pos=hero.global_position
		from_idle_or_run_to_do()
		$get_hero_body.rotation_degrees=fnc.angle(get_input(hero.global_position))
		$hirtbox.rotation_degrees=$get_hero_body.rotation_degrees
	if state=="d":
		set_anim(statuses[state])
		vec=Vector2.ZERO
		cur_target_pos=global_position
		na.set_velocity(vec)
	new_dos(_delta)
func new_dos(_delta:float):
	pass

func post_status():
	pass


func move(safe_velocity):
	if state=="r":
		set_linear_velocity(safe_velocity)
	else:
		set_linear_velocity(Vector2(0,0))

func from_idle_or_run_to_do():
	match current_action:
		1:
			if can_attack and attacks_timer>=attack1_time_period:
				state="a"
			
func _on_ap_animation_finished(anim_name):
	anim_finish=true
func _on_hurt_box_no_he():
	set_linear_velocity(Vector2.ZERO)
	delete()
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
	state="d"

var bs=[]
func _on_get_hero_body_body_entered(b):
	if b!=self and b.is_in_group("border")==false:
		bs.append(b)


func _on_get_hero_body_body_exited(b):
	if b!=self and b.is_in_group("border")==false:
		bs.remove_at(fnc.i_search(bs,b))

