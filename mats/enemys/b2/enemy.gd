extends "res://mats/enemys/enemy_s.gd"
@export_group("attack2")
@export_range(0,99999) var attack2_time_period:float=2.0
@export var attack2_range:float=30
@export var move_speed_in_attack2:float=200
@export_subgroup("damage")
@export_range(1,999999999) var damage2_from:float=1.0
@export_range(1,999999999) var damage2_to:float=2.0
@export var pos2_from:float=-10
@export var pos2_to:float=10
@export_range(-180,180) var angle2_from:float=-45
@export_range(-180,180) var angle2_to:float=45
@export_subgroup("crit_damage")
@export_range(1,999999999) var crit_damage2_from:float=1.0
@export_range(1,999999999) var crit_damage2_to:float=4.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var crit_chance2_from:float=0
@export_range(0.0,1.0) var crit_chance2_to:float=0
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
var can_attack2:bool=false
var can_speed:bool=false
signal die(n)
var bname:int=0
func _on_die():
	emit_signal("die",bname)
func pre_ready():
	connect("die",Callable(get_tree().current_scene, "boss_die"))
func past_ready():
	var damage1=0
	if !elite:
		damage1=set_param(damage2_from,damage2_to,dif)
	else:
		damage1=set_param(damage2_from,damage2_to,dif)*1.5
	$ra_hirtbox.damage=damage1

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
	pol=PackedVector2Array([])
	tang=abs(angle2_from)+abs(angle2_to)
	ang=tang/dots
	if pos2_from==pos2_to and pos2_to==0:
		pol.append(Vector2.ZERO)
	else:
		pol.append(Vector2(0,pos2_to))
		pol.append(Vector2(0,pos2_from))
	for e in range(dots+1):
		pol.append(fnc.move(e*ang+angle2_from)*attack2_range)
	$ra_hirtbox/col.polygon=pol
func summon(type:int=1,difficulty:float=2):
	var amout=0
	var spwn_ang=0
	var ang1
	var to_hero=target_position-global_position
	if type==0:
		amout=5-1#randi_range(wskel_amout_from,wskel_amout_to)-1
		spwn_ang=60
		ang1=spwn_ang/float(amout)
		for e in range(amout+1):
			var ang=fnc.angle(to_hero)-spwn_ang/2
			var rast=randi_range(spwn_range_from,spwn_range_to)
			var pos=fnc.move(ang+e*ang1)*rast+global_position
			var en=preload("res://mats/enemys/e1/enemy.tscn").instantiate()
			en.load_scene=preload("res://mats/enemys/e1/enemy.tscn")
			en.scene_params={
				"global_position":pos,
				"dif":dif,
				"elite":true
			}
			en.global_position=pos
			get_parent().add_child.call_deferred(en)
	else:
		amout=randi_range(cskel_amout_from,cskel_amout_to)-1
		spwn_ang=360
		ang1=spwn_ang/float(amout)
		for e in range(amout):
			var ang=fnc.angle(to_hero)-spwn_ang/2
			var rast=randi_range(spwn_range_from,spwn_range_to)
			var pos=fnc.move(ang+e*ang1)*rast+global_position
			var en=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
			var ens=[
					"res://mats/enemys/e1/enemy.tscn",
					"res://mats/enemys/e2/enemy.tscn"
					]
			ens.shuffle()
			en.load_scene=load(ens[0])
			en.scene_params={
				"global_position":pos,
				"dif":dif,
				"elite":true
			}
			en.global_position=pos
			get_parent().add_child.call_deferred(en)
func in_status_think():
	$ra_hirtbox.rotation_degrees=$get_hero_body.rotation_degrees
	if current_action==1:
		current_action=0
	if can_attack and attacks_timer>=attack1_time_period and state!="a2":
		state="a"
	can_attack2=get_visual_contact_with(hero)
	if (can_attack2 or current_action==2) and attacks_timer>=attack2_time_period and state!="a":
		state="a2"
func new_dos(_delta:float):
	if state=="a":
		attacks_timer=0
		vec=Vector2.ZERO
		set_anim(statuses[state],hero.global_position)
		target_position=hero.global_position
		state="wait_anim"
		na.set_velocity(vec)
	if state=="a2":
		attacks_timer=0
		cur_target_pos=global_position+(hero.global_position-global_position).normalized()*move_speed_in_attack2
		set_anim(statuses[state],hero.global_position)
		target_position=hero.global_position
		state="wait_anim"
func set_speed():
		vec=(hero.global_position-global_position).normalized()*move_speed_in_attack2
		na.max_speed=move_speed_in_attack2
		na.set_velocity(vec)
