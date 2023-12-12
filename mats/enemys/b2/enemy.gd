extends "res://mats/contents/base/charter_tamplate.gd"
@export_category("attack2_speed")
var attack2_speed=100
func past_ready():
	$stages.centerize=true
	$stages.max_value=hb.m_he
	$stages.max_stage_points=2
	$stages.think()
func in_status_think():
	if $attack2.active==true and (eye_contact_with(target) or current_action=="a2") and attacks_timer>=$attack2.attack_time_period and state!="a1" and state!="s":
		state="a2"
	if $attack.active==true and $attack.bs!=[] and current_action=="a1" and attacks_timer>=$attack.attack_time_period and eye_contact_with(target) and state!="a2" and state!="s":
		state="a1"
	if len($stages.stages)!=0 and $stages.stages[len($stages.stages)-1]>hb.he and $summon.active:
		$stages.remove_stage(len($stages.stages)-1)
	if $attack.active==true and current_action=="a2" and $attack.bs!=[]:
		current_action="a1"

func pre_status():
	$attack.rotation_degrees=fnc.angle(global_position.direction_to(na.get_next_path_position()))
func new_dos(_delta:float):
	if state=="a1":
		attacks_timer=0
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)
	if state=="a2":
		attacks_timer=0
		cur_target_pos=global_position+(target.global_position-global_position).normalized()*attack2_speed
		set_anim(statuses[state],target.global_position)
		$attack2.rotation_degrees=fnc.angle(global_position.direction_to(target.global_position))
		state="wait_anim"
	if state=="s":
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)

func set_speed():
	na.max_speed=attack2_speed
	na.set_velocity(global_position.direction_to(na.get_next_path_position()).normalized()*attack2_speed)
func summon():
	$summon.summon()
func _on_die():
	$drop.drop()
	$boss_mark.emit()
func _on_stages_stage_changed(curent_stage):
	state="s"
