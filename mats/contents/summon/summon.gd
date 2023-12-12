extends Node2D
@export var node_path:NodePath="../"
@export var do_name:String=""
@export var do_anim_name:String=""
@export var active:bool=true
@export_range(0,1) var percent:float=0
@export_range(1,99999)var count:int=1
@export_range(0,99999) var time_period:float=2.0
@export var auto_rotate:bool=false
@export_range(-180,180)var rotate_offset:float=0
@export_enum("circle","rand","custom")var type:int=0
@export_group("custom")
@export var custom_scene:PackedScene
@export var custom_summon_radius:float=50
@export var custom_data={}
func pre_ready():pass
func past_ready():pass
func _ready():
	pre_ready()
	if active==true:
		var n=get_node(node_path)
		if percent!=0:
			n.doing_chance_list.merge({do_name:percent})
		n.statuses.merge({do_name:do_anim_name})
	past_ready()
func summon():
	match type:
		0:
			var spwn_ang=360
			var ang1=spwn_ang/float(count)
			for e in range(count):
				var ang=-spwn_ang/2
				var rast=75
				var pos=fnc.move(ang+e*ang1)*rast+global_position
				var en=preload("res://mats/contents/summoner/summoner.tscn").instantiate()
				var perc=[]
				for enemy in gm.maps[gm.get_cur_lvl()].enemys.keys():
					perc.append(gm.maps[gm.get_cur_lvl()].enemys[enemy])
				var enemy=gm.maps[gm.get_cur_lvl()].enemys.keys()[fnc._with_chance_ulti(perc)]
				en.load_scene=load(gm.enemys[enemy].s)
				en.scene_data={
					"global_position":pos,
					"elite":fnc._with_chance(0.1)
				}
				en.global_position=pos
				get_tree().current_scene.ememys_path.add_child(en)
		1:
			var spwn_ang=360
			var ang1=spwn_ang/float(count)
			for e in range(count):
				var rast=75
				var pos=get_tree().current_scene.get_rand_pos()
				var en=preload("res://mats/contents/summoner/summoner.tscn").instantiate()
				var perc=[]
				for enemy in gm.maps[gm.get_cur_lvl()].enemys.keys():
					perc.append(gm.maps[gm.get_cur_lvl()].enemys[enemy])
				var enemy=gm.maps[gm.get_cur_lvl()].enemys.keys()[fnc._with_chance_ulti(perc)]
				print(gm.enemys[enemy].s)
				en.load_scene=load(gm.enemys[enemy].s)
				en.scene_data={
					"global_position":pos,
					"elite":fnc._with_chance(0.1)
				}
				en.global_position=pos
				get_tree().current_scene.ememys_path.add_child(en)
		2:
			var ang=360.0/float(count)
			for i in range(count):
				var e=custom_scene.instantiate()
				fnc.setter(e,custom_data)
				if auto_rotate:
					e.rotation_degrees=ang*i+global_rotation_degrees+rotate_offset
				e.set_deferred("global_position",global_position+fnc.move(rotation_degrees+ang*i)*custom_summon_radius)
				get_tree().current_scene.ememys_path.add_child(e)
	pass
