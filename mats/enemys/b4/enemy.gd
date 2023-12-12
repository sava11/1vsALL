extends "res://mats/contents/base/charter_tamplate.gd"

@export_group("fierball stats")
@export_subgroup("damage")
@export var static_damage:bool=false
@export_range(1,999999999) var damage_from:float=1.0
@export_range(1,999999999) var damage_to:float=2.0
@export_subgroup("crit_damage")
@export var static_crit:bool=false
@export_range(1,999999999) var crit_damage_from:float=1.0
@export_range(1,999999999) var crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export var static_crit_chance:bool=false
@export_range(0.0,1.0) var crit_chance_from:float=0
@export_range(0.0,1.0) var crit_chance_to:float=0
func to_idle():
	return state!="t"
func past_ready():
	$stages.centerize=true
	$stages.max_value=hb.m_he
	$stages.max_stage_points=5
	$stages.think()
	$summon.custom_data={
		"speed":200,
		"acc_speed":150,
		"damage":fnc._with_dific(randf_range(damage_from,damage_to),dif),
		"crit_damage":fnc._with_dific(randf_range(crit_chance_from,crit_chance_to),dif),
		"crit_chance":fnc._with_dific(randf_range(crit_damage_from,crit_damage_to),dif),
	}
func in_status_think():
	if to_idle():
		if $stages.active and len($stages.stages)!=0 and $stages.stages[len($stages.stages)-1]>hb.he:
			$stages.remove_stage(len($stages.stages)-1)
		if $attack.active and $attack.bs!=[] and attacks_timer>$attack.attack_time_period and eye_contact_with(target):
			state="a3"
		if $summon.active==true and current_action=="sfb" and attacks_timer>$summon.time_period and eye_contact_with(target):
			state=current_action
func pre_status():
	#print(state)
	$summon.rotation_degrees=fnc.angle(target.global_position-global_position)
func new_dos(_delta:float):
	if state=="sfb":
		attacks_timer=0
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)
	if state=="a3":
		attacks_timer=0
		set_anim(statuses[state],target.global_position)
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)
	if state=="t":
		set_anim(statuses[state])
		state="wait_anim"
		na.set_velocity(Vector2.ZERO)

func _on_die():
	$drop.drop()
	$boss_mark.emit()
func teleport():
	var e=preload("res://mats/contents/damage/circle_wave/damage.tscn").instantiate()
	fnc.setter(e,{
		"collision_layer":2,
		"autoset":true,
		"damage":2.5,
		"crit_damage":2.0,
		"crit_chance":0.3,
		"sqrt_per_sec":5,
		"del_sqrt":250,
	})
	e.set_deferred("global_position",global_position)
	get_tree().current_scene.ememys_path.add_child(e)
	global_position=get_tree().current_scene.get_rand_pos()


func _on_stages_stage_changed(curent_stage):
	state="t"
