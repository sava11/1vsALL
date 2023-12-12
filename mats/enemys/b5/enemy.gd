extends "res://mats/contents/base/charter_tamplate.gd"
@onready var s=$summon
@onready var s2=$summon2
@onready var a=$attack
func in_status_think():
	if a.active==true and a.bs!=[] and current_action==a.attack_name and attacks_timer>=a.attack_time_period:
		state=a.attack_name
	if s.active==true and current_action==s.do_name and attacks_timer>=s.time_period:
		state=s.do_name
	if s2.active==true and current_action==s2.do_name and attacks_timer>=s2.time_period:
		state=s2.do_name
func past_ready():
	print(dif)
	s.custom_data={
		"dots":3,
		"width":0.5,
		"zone_angle":360/float(s.count),
		"collision_layer":2,
		"collision_mask":8,
		"autoset":true,
		"damage":fnc._with_dific(0.8,dif),
		"crit_damage":fnc._with_dific(2.0,dif),
		"crit_chance":0.3,
		"sqrt_per_sec":12.5,
		"del_sqrt":632,
	}
	s2.custom_data={
		"dif":dif,
	}
func pre_status():
	a.rotation_degrees=fnc.angle(global_position.direction_to(target.global_position))
func new_dos(_delta:float):
	if state==a.attack_name:
		attacks_timer=0
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)
	if state==s.do_name:
		attacks_timer=0
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)
	if state==s2.do_name:
		attacks_timer=0
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)
func _on_die():
	$drop.drop()
	$boss_mark.emit()
