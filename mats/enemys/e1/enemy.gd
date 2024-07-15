extends "res://mats/contents/base/charter_tamplate.gd"

func in_status_think():
	if $attack.bs!=[] and current_action==$attack.attack_name and attacks_timer>=$attack.attack_time_period:
		state=current_action

func pre_status():
	$attack.rotation_degrees=fnc.angle(global_position.direction_to(na.get_next_path_position()))
func new_dos(_delta:float):
	if state=="a1":
		attacks_timer=0
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)
	
func _on_die():
	$drop.drop()
