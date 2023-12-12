extends "res://mats/contents/base/charter_tamplate.gd"
@export_range(0.001,999)var life_time_from:float=4
@export_range(0.001,999)var life_time_to:float=8

# Called when the node enters the scene tree for the first time.
func past_ready():
	$t.start(fnc.rnd.randf_range(life_time_from,life_time_to))

func _on_t_timeout():
	delete()
	var e=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
	var ens=get_tree().current_scene.cur_enemys.duplicate()
	var itms_v=[]
	var itms=[]
	for en in ens.keys():
		itms_v.append(ens[en])
	for en in ens.keys():
		itms.append(en)
	e.load_scene=load(gm.enemys[itms[fnc._with_chance_ulti(itms_v)]].s)
	e.time=0.5
	e.time_curve=Curve.new()
	e.time_curve.add_point(Vector2(0,1))
	e.time_curve.add_point(Vector2(5,0.7))
	e.time_curve.add_point(Vector2(1,0.3))
	e.scene_data={
		"global_position":global_position,
		"dif":dif,
		"elite":fnc._with_chance(0.01)
		}
	#e.target_path=fnc.get_hero().get_path()
	get_tree().current_scene.ememys_path.add_child(e)
	e.global_position=global_position
	queue_free()



func _on_hurt_box_no_he():
	queue_free()
