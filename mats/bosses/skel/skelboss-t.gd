extends "res://mats/enemys/enemy_s.gd"

@export_group("summon")
@export_enum("skel_wall","skel_circle")var summon_type:int=0
@export_range(1,99999) var spwn_range_from:int=25
@export_range(1,99999) var spwn_range_to:int=50
@export_subgroup("skel_wall")
@export_range(1,99999) var wskel_amout_from:int=3
@export_range(1,99999) var wskel_amout_to:int=8
@export_subgroup("skel_circle")
@export_range(1,99999) var cskel_amout_from:int=4
@export_range(1,99999) var cskel_amout_to:int=6
func _summon(type:int=1,difficulty:float=2):
	var amout=0
	var spwn_ang=0
	var ang1
	if type==0:
		amout=5-1#randi_range(wskel_amout_from,wskel_amout_to)-1
		spwn_ang=60
		ang1=spwn_ang/float(amout)
		for e in range(amout+1):
			var ang=fnc.angle(na)-spwn_ang/2
			var rast=randi_range(spwn_range_from,spwn_range_to)
			var pos=fnc.move(ang+e*ang1)*rast+global_position
			var en=preload("res://mats/enemys/e1/enemy.tscn").instantiate()
			en.load_scene=preload("res://mats/enemys/e1/enemy.tscn")
			en.scene_params={
				"global_position":pos,
				"dif":dif+0.5
			}
			en.global_position=pos
			get_parent().add_child.call_deferred(en)
	else:
		amout=randi_range(cskel_amout_from,cskel_amout_to)-1
		spwn_ang=360
		ang1=spwn_ang/float(amout)
		for e in range(amout):
			var ang=fnc.angle(mvd)-spwn_ang/2
			var rast=randi_range(spwn_range_from,spwn_range_to)
			var pos=fnc.move(ang+e*ang1)*rast+global_position
			var en=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
			var ens=[
					"res://mats/enemys/e1/enemy.tscn",
					"res://mats/enemys/e2/enemy.tscn"
					]
			ens.shuffle()
			en.load_scene=load(ens[0])
			en.scene_params={
				"global_position":pos,
				"dif":dif+0.5
			}
			en.global_position=pos
			get_parent().add_child.call_deferred(en)
	summoning=false
