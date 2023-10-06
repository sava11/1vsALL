extends "res://mats/enemys/enemy_s.gd"
@export_group("healself")
@export_range(0.01,100) var point_per_sec:float=1
@onready var healing_timer=snapped($ap.get_animation("heal").length,0.1)
var heal_time=0
signal die(n)
var bname=""
var heal_stages=[]
var heal_points_per_sec=0
var max_heal_points=2
var current_heal_points=max_heal_points

func _on_die():
	emit_signal("die",bname)
func pre_ready():
	connect("die",Callable(get_tree().current_scene, "boss_die"))
func past_ready():
	for e in range(max_heal_points):
		heal_stages.append(hb.m_he*e*0.5+(float(hb.m_he)/max_heal_points/3))
	heal_points_per_sec=fnc._with_dific(point_per_sec,dif)

	#pb.get_node("txt").text="\thp: "+str(hb.he)
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
func summon(type:int=1,difficulty:float=2):
	pass
func in_status_think():
	if can_attack and attacks_timer>=attack1_time_period and state!="h":
		state="a"
	if len(heal_stages)!=0 and heal_stages[len(heal_stages)-1]>hb.he:
		state="preh"
func to_idle():
	return state!="a" and state!="h" and state!="preh"

func new_dos(_delta:float):
	if state=="a":
		attacks_timer=0
		vec=Vector2.ZERO
		set_anim(statuses[state],hero.global_position)
		target_position=hero.global_position
		state="wait_anim"
		na.set_velocity(vec)
	if state=="preh":
		get_tree().current_scene.summon(20)
		heal_stages.remove_at(len(heal_stages)-1)
		vec=Vector2.ZERO
		na.set_velocity(vec)
		state="h"
	if state=="h":
		set_anim(statuses[state])
		heal_time+=_delta
		if heal_time<healing_timer and hb.he<hb.m_he:
			hb.set_he(hb.he+heal_points_per_sec*_delta)
		else:
			heal_time=0
			state="i"
			
