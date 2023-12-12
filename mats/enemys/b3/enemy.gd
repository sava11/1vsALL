extends "res://mats/contents/base/charter_tamplate.gd"

func to_idle():
	return state!="h"
func past_ready():
	hb.get_node("healing").healing_timer=snapped(ap.get_animation("heal").length,0.1)
	$stages.centerize=true
	$stages.max_value=hb.m_he
	$stages.max_stage_points=3
	$stages.think()
	$hurt_box/healing.heal_per_sec=fnc._with_dific(hb.m_he/$stages.max_stage_points,dif)
func in_status_think():
	if $attack.active==true and $attack.bs!=[] and current_action=="a1" and attacks_timer>=$attack.attack_time_period and eye_contact_with(target) and state!="h":
		state=current_action
	if $stages.active and len($stages.stages)!=0 and $stages.stages[len($stages.stages)-1]>hb.he:
		$stages.remove_stage(len($stages.stages)-1)

func pre_status():
	$attack.rotation_degrees=fnc.angle(global_position.direction_to(na.get_next_path_position()))
func new_dos(_delta:float):
	if state=="a1":
		attacks_timer=0
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)
	if state=="h":
		set_anim(statuses[state],target.global_position)
		na.set_velocity(Vector2.ZERO)
	#print(state)
func summon():
	$summon.summon()
func _on_die():
	$drop.drop()
	$boss_mark.emit()
func _on_stages_stage_changed(curent_stage):
	state="h"
	$hurt_box/healing.healing=true
	summon()

func _on_healing_healing_end():
	state="i"
