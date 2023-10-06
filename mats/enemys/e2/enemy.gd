extends "res://mats/enemys/enemy_s.gd"
func in_status_think():
	if get_visual_contact_with(hero) and get_sqrt(hero)<save_sqrt:
		cur_target_pos=global_position+(global_position-hero.global_position).normalized()*save_sqrt
		state="r"
	if can_attack and attacks_timer>=attack1_time_period:
		state="a"
func summon_arrow():
	var a=preload("res://mats/enemys/e2/arrow.tscn").instantiate()
	a.position=global_position+(target_position-global_position).normalized()*10
	a.global_rotation_degrees=fnc.angle(target_position-global_position)-90
	var damage=fnc._with_dific(randf_range(damage_from,damage_to),dif)
	a.start_pos=global_position
	#a.get_node("s").position.y-=10
	a.damage=damage
	a.sqrt=fnc._sqrt(target_position-global_position)
	a.speed=100
	a.sqrt=attack_range
	a.mvd=(target_position-global_position).normalized()
	get_tree().current_scene.ememys_path.add_child(a)
func aiming():
	var e=preload("res://mats/font/crit.tscn").instantiate()
	e.hide()
	e.texture=load(gm.images.icons.other.aim)
	e.global_position=global_position+Vector2(-e.size.x/2,-36)
	get_tree().current_scene.ememys_path.add_child(e)
func set_att_zone():
	var pol=PackedVector2Array([])
	pol.append(Vector2(0,5))
	pol.append(Vector2(attack_range,5))
	pol.append(Vector2(attack_range,-5))
	pol.append(Vector2(0,-5))
	$hirtbox/col.polygon=pol
	$get_hero_body/c.polygon=pol
func _draw():
	if state=="wait_anim":
		draw_line(Vector2.ZERO,(target_position-global_position).normalized()*attack_range,Color(1.0,0,0,0.2),4,true)
