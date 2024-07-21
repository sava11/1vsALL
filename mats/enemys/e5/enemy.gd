extends "res://mats/contents/base/charter_tamplate.gd"

@export_group("parametrs")
@export_range(0,99) var max_tp_points=1
var tp_stages=[]

func _draw():
	if cur_anim=="attack":
		var count=8
		var ang=360.0/float(count)
		for e in range(count):
			draw_line(Vector2.ZERO,fnc.move(e*ang+fnc.angle(target_position-global_position))*attack_range,Color(1.0,0,0,0.2),4,true)

func aiming():
	var e=preload("res://mats/font/crit.tscn").instantiate()
	e.hide()
	e.texture=load(gm.images.icons.other.aim)
	e.global_position=global_position+Vector2(-e.size.x/2,-36)
	get_tree().current_scene.ememys_path.add_child(e)

func summon_arrow():
	var count=8
	var ang=360.0/float(count)
	for e in range(count):
		var s=preload("res://mats/enemys/e5/arrow.tscn").instantiate()
		s.speed=200
		s.global_position=global_position
		s.global_rotation_degrees=ang*e+fnc.angle(target_position-global_position)
		s.start_pos=global_position
		#s.get_node("s").position.y-=10
		s.damage=$hirtbox.damage
		s.crit_chance=$hirtbox.crit_chance
		s.crit_damage=$hirtbox.crit_damage
		s.sqrt=attack_range
		get_tree().current_scene.ememys_path.add_child(s)
func pre_status():
	print(state)
	pass
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
func in_status_think():
	if get_visual_contact_with(hero) and get_sqrt(hero)<save_sqrt:
		cur_target_pos=global_position+(global_position-hero.global_position).normalized()*save_sqrt
		state="r"
	var summon=len(tp_stages)!=0 and tp_stages[len(tp_stages)-1]>hb.he
		#print(summon_stages[len(summon_stages)-1]," ",hb.he)
	if summon:
		tp_stages.remove_at(len(tp_stages)-1)
		state="t"
	
	if can_attack and attacks_timer>=attack1_time_period:
		state="a"
func teleport():
	global_position=get_tree().current_scene.get_rand_pos()
