extends "res://mats/enemys/enemy_s.gd"
@export_group("parametrs")
@export_range(0,99) var max_tp_points=1
var tp_stages=[]
var tp_rast=100
@export_range(0,99999) var max_damage_per_sec_from:float
@export_group("attack3")
@export_range(0,99999) var attack3_time_period:float=2.0
@export var attack3_range:float=30
@export_subgroup("damage")
@export_range(1,999999999) var a3_damage_from:float=1.0
@export_range(1,999999999) var a3_damage_to:float=2.0
@export var a3_pos_from:float=-10
@export var a3_pos_to:float=10
@export_range(-180,180) var a3_angle_from:float=-45
@export_range(-180,180) var a3_angle_to:float=45
@export_subgroup("crit_damage")
@export_range(1,999999999) var a3_crit_damage_from:float=1.0
@export_range(1,999999999) var a3_crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var a3_crit_chance_from:float=0
@export_range(0.0,1.0) var a3_crit_chance_to:float=0
signal die(n)
var bname=""
func _on_die():
	emit_signal("die",bname)
var a3_dmg=0
var a3_dmg_c=0
var a3_crit_c=0
func pre_ready():
	connect("die",Callable(get_tree().current_scene, "boss_die"))
	a3_dmg=set_param(a3_damage_from,a3_damage_to,dif)
	a3_dmg_c=set_param(a3_crit_damage_from,a3_crit_damage_to,dif)
	a3_crit_c=set_param(a3_crit_chance_from,a3_crit_chance_to,dif)
	#attack2_dmg=set_param(a2_damage_from,a2_damage_to,dif)

func set_att_zone():
	
	var pol=PackedVector2Array([])
	pol.append(Vector2(0,5))
	pol.append(Vector2(attack_range,5))
	pol.append(Vector2(attack_range,-5))
	pol.append(Vector2(0,-5))
	$get_hero_body/c.polygon=pol
	pol=PackedVector2Array([])
	pol.append(Vector2(0,5))
	pol.append(Vector2(attack3_range,5))
	pol.append(Vector2(attack3_range,-5))
	pol.append(Vector2(0,-5))
	$hirtbox/col.polygon=pol
	for e in range(max_tp_points):
		tp_stages.append(hb.m_he*e*0.5+(hb.m_he/max_tp_points/2))
func _draw():
	if cur_anim=="attack":
		draw_line(Vector2.ZERO,fnc.move(fnc.angle(target_position-global_position))*attack_range,Color(1.0,0,0,0.2),4,true)

func aiming():
	var e=preload("res://mats/font/crit.tscn").instantiate()
	e.hide()
	e.texture=load(gm.images.icons.other.aim)
	e.global_position=global_position+Vector2(-e.size.x/2,-36)
	get_tree().current_scene.ememys_path.add_child(e)

func summon_arrow():
	var s=preload("res://mats/enemys/smart_fireball/smart_fireball.tscn").instantiate()
	s.speed=200
	s.acc_speed=150
	#s.get_node("s").position.y-=10
	s.damage=$hirtbox.damage
	s.crit_chance=$hirtbox.crit_chance
	s.crit_damage=$hirtbox.crit_damage
	get_tree().current_scene.ememys_path.add_child.call_deferred(s)
	s.set_deferred("global_position",global_position+fnc.move(fnc.angle(target_position-global_position))*25)
func summon_cust_dmg():
	var s=preload("res://mats/boxes/custom_dmg_area.tscn").instantiate()
	s.think(attack3_range)
	s.del_time=0.0001
	s.damage=a3_dmg
	s.crit_chance=a3_dmg_c
	s.crit_damage=a3_crit_c
	s.collision_layer=2
	get_tree().current_scene.ememys_path.add_child.call_deferred(s)
	s.set_deferred("global_position",global_position)
	

func new_dos(_delta:float):
	if state=="t":
		$ap.play("teleporting")
		state="wait_anim"
	if state=="a":
		attacks_timer=0
		vec=Vector2.ZERO
		set_anim(statuses[state],hero.global_position)
		target_position=hero.global_position
		state="wait_anim"
		na.set_velocity(vec)
	if state=="a2":
		attacks_timer=0
		vec=Vector2.ZERO
		set_anim(statuses[state],hero.global_position)
		target_position=hero.global_position
		state="wait_anim"
		na.set_velocity(vec)
	if state=="a3":
		attacks_timer=0
		vec=Vector2.ZERO
		set_anim(statuses[state],hero.global_position)
		target_position=hero.global_position
		state="wait_anim"
		na.set_velocity(vec)
func in_status_think():
	if get_visual_contact_with(hero) and get_sqrt(hero)<save_sqrt:
		cur_target_pos=global_position+(global_position-hero.global_position).normalized()*save_sqrt
		state="r"
	var summon=len(tp_stages)!=0 and tp_stages[len(tp_stages)-1]>hb.he
		#print(summon_stages[len(summon_stages)-1]," ",hb.he)
	if summon:
		tp_stages.remove_at(len(tp_stages)-1)
		state="t"
	if can_attack and attacks_timer>=attack1_time_period :
		state="a"
	if can_attack and get_sqrt(hero)<attack3_range  and attacks_timer>=attack3_time_period :
		state="a3"
func teleport():
	var pos=get_tree().current_scene.get_rand_pos()
	var rst=0
	while rst<tp_rast:
		pos=get_tree().current_scene.get_rand_pos()
		rst=fnc._sqrt(pos)
	set_deferred("global_position",pos)
