extends RigidBody2D
@export_group("parametrs")
@export_range(0,100) var dif:float=1
@export var run_speed:float=45.0
@export var save_sqrt:float=150
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
@export_group("attack3")
@export_range(0,99999) var aura_time_period:float=17.0
@export_subgroup("def")
@export var aura_def_from:float=1.0
@export var aura_def_to:float=1.0
@export_subgroup("life_time")
@export var aura_life_time_from:float=5.0
@export var aura_life_time_to:float=5.0
@export_group("attack2")
@export_range(0,99999) var attack2_time_period:float=5.0
@export_subgroup("damage")
@export_range(1,999999999) var s_damage_from:float=1.0
@export_range(1,999999999) var s_damage_to:float=2.0
@export_subgroup("crit_damage")
@export_range(1,999999999) var s_crit_damage_from:float=1.0
@export_range(1,999999999) var s_crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var s_crit_chance_from:float=0
@export_range(0.0,1.0) var s_crit_chance_to:float=0
@export_group("attack1")
@export_range(0,99999) var attack1_time_period:float=2.0
@export var attack_range:float=75
@export_subgroup("damage")
@export_range(1,999999999) var damage_from:float=1.0
@export_range(1,999999999) var damage_to:float=2.0
@export_subgroup("crit_damage")
@export_range(1,999999999) var crit_damage_from:float=1.0
@export_range(1,999999999) var crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var crit_chance_from:float=0
@export_range(0.0,1.0) var crit_chance_to:float=0
@onready var hero=fnc.get_hero()
@onready var hb=$hurt_box
@onready var at=$at

var do_stages=[]
var max_do_points=2
var current_do_points=max_do_points
#timers
var attacks_timer:float=0

var vec:Vector2=Vector2.ZERO
var last_mvd:Vector2=Vector2.ZERO
var mvd:Vector2=Vector2.ZERO
enum status{a1,a2,a3,d,i,r,wait_anim}
var state=status.i


func get_sqrt(obj):
	return fnc._sqrt(obj.global_position-global_position)
var last_anim:int=0
func set_anim(anim_name:String,oneshoot:bool=false,changeing_pos:bool=true):
	var tname=""
	var anim=get_ang_move(rad_to_deg(mvd.angle())+180,90)*int(changeing_pos)+last_anim*int(!changeing_pos)
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
	else:
		$sp.animation=anim_name+tname
		$ap.play(anim_name)
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
func _ready():
	hb.monitorable=true
	hb.monitoring=true
	
	var life_points=0
	var damage=0
	var def=0
	life_points=fnc._with_dific(randf_range(life_points_from,life_points_to),dif)
	def=fnc._with_dific(randf_range(defence_from,defence_to),dif)
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	hb.s_m_d(def)
	hb.set_def(def)
	for e in range(max_do_points):
		do_stages.append(hb.m_he*e*0.5+(hb.m_he/max_do_points/2))
	print(do_stages)
	at.active=true
	#at["parameters/conditions/death"]=false
	pass

var think_timer:float=0
var think_time:float=1
var current_action:int=0
func thinker():
	if think_timer>=think_time and current_action==0:
		think_timer=0
		current_action=fnc._with_chance_ulti([0.3,0.7])+1
func _integrate_forces(st):
	vec=st.get_linear_velocity()
	mvd=get_input(hero.global_position)
	if mvd!=Vector2.ZERO and mvd!=last_mvd:
		last_mvd=mvd
	pre_status()
	match_status(st.get_step())
	post_status()
	#set_anim()
	st.set_linear_velocity(vec)
func pre_status():
	pass
func timers(_delta):
	attacks_timer+=_delta
	think_timer+=_delta
func match_status(_delta:float):
	match state:
		status.wait_anim:
			if anim_finish:
				state=status.i
				current_action=0
		status.a1:
			attacks_timer=0
			vec=Vector2.ZERO
			set_anim("attack1")
			state=status.wait_anim
		status.a2:
			attacks_timer=0
			set_anim("attack2",true,false)
			vec=Vector2.ZERO
			state=status.wait_anim
		status.a3:
			set_anim("attack3")
			vec=Vector2.ZERO
			state=status.wait_anim
		status.r:
			var moveing=get_sqrt(hero)>=attack_range
			if moveing:
				set_anim("run")
				vec=mvd*run_speed
				timers(_delta)
				thinker()
				from_idle_or_run_ta_attacks()
			else:
				state=status.i
				
		status.i:
			set_anim("idle")
			vec=Vector2.ZERO
			timers(_delta)
			thinker()
			if get_sqrt(hero)>attack_range:
				state=status.r
			from_idle_or_run_ta_attacks()
		status.d:
			set_anim("death")
			vec=Vector2.ZERO
func post_status():
	pass
func from_idle_or_run_ta_attacks():
	if len(do_stages)!=0 and do_stages[len(do_stages)-1]>hb.he:
		do_stages.remove_at(len(do_stages)-1)
		current_action=3
		#print(summon_stages[len(summon_stages)-1]," ",hb.he)
		
	match current_action:
		1:
			if get_sqrt(hero)<=attack_range and attacks_timer>=attack1_time_period:
				state=status.a1
		2:
			if attacks_timer>=attack2_time_period:
				state=status.a2
		3:
			state=status.a3
			
func spawn_def_aura():
	var s=preload("res://mats/items/aura/aura.tscn").instantiate()
	var aura_def=0
	var life_time_period=0
	aura_def=fnc._with_dific(randf_range(aura_def_from,aura_def_to),dif)
	life_time_period=fnc._with_dific(randf_range(aura_def_from,aura_def_to),dif)
	s.m_he=aura_def
	s.life_time_period=life_time_period
	s.position=Vector2.ZERO
	s.owner_node_path=get_path()
	add_child(s)
	get_node("hurt_box").set_deferred("monitoring",false)
	get_node("hurt_box").set_deferred("monitorable",false)
func summon_souls():
	var counts=3
	var ang=360/counts
	for e in range(counts):
		var a=preload("res://mats/enemys/e6/soul.tscn").instantiate()
		var damage=fnc._with_dific(randf_range(s_damage_from,s_damage_to),dif)
		a.start_pos=global_position+fnc.move(ang*e)*50
		a.damage=damage
		a.speed=50
		a.acc=20
		a.target=hero
		get_tree().current_scene.ememys_path.add_child(a)
func summon_blood_arrows():
	var counts=5
	var ang=180.0/float(counts)
	for e in range(counts):
		var a=preload("res://mats/enemys/e6/blood_arrow/blood_arrow.tscn").instantiate()
		a.rotation_degrees=ang*e+fnc.angle(last_mvd)-ang*(counts/2)
		var damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)
		a.start_pos=global_position+fnc.move(a.rotation_degrees)*15
		a.damage=damage
		a.crit_chance=fnc._with_dific(randf_range(crit_chance_from,crit_chance_to),dif)
		a.crit_damage=fnc._with_dific(randf_range(crit_damage_from,crit_damage_to),dif)
		a.speed=150
		a.sqrt=600
		get_tree().current_scene.ememys_path.add_child(a)

func _on_ap_animation_finished(anim_name):
	anim_finish=true
func _on_hurt_box_no_he():
	delete()
func delete():
	state=status.d
