class_name level_template extends Node2D
@export var time:float
@export var cam:Camera2D
@export var enemys_data:Array[empty_entety_data]
var rsize:Vector2
var rpos:Vector2
var timer:Timer
var ememys_path:Node
signal completed(res:bool)
func start_timer():
	timer=Timer.new()
	timer.wait_time=time
	timer.name="Timer"
	add_child(timer)
	timer.start()
func _ready():
	if ememys_path!=null:
		ememys_path=get_node("../ent/ememys")
	rsize=$arena_brd.size
	rpos=$arena_brd.global_position
	var cm_brd=$cam_brd
	var cam_scale:float=fnc.get_prkt_win().x/cm_brd.size.x
	if cam!=null:
		timer.timeout.connect(Callable(self,"emit_signal").bind("completed",true))
		if time>0:
			start_timer()
		if cam_scale>1.25:
			cam.zoom=Vector2(cam_scale,cam_scale)
		cam.limit_left=cm_brd.position.x
		cam.limit_top=cm_brd.position.y
		cam.limit_bottom=cm_brd.position.y+cm_brd.size.y
		cam.limit_right=cm_brd.position.x+cm_brd.size.x
		fnc.get_hero().global_position=$pos.global_position

func get_rand_pos():
	var c:NavigationMesh=$nav.navigation_polygon.get_navigation_mesh()
	var gpols=[]
	for e in range(c.get_polygon_count()):
		var pol:PackedVector2Array=PackedVector2Array([])
		for pid in c.get_polygon(e):
			pol.append(Vector2(c.vertices[pid].x,c.vertices[pid].z))
		gpols.append(pol)
	var pos=Vector2.ZERO
	var finded=false
	while !finded:
		var x=0
		var y=0
		var x1=0
		var y1=0
		x=rpos.x
		x1=rpos.x+rsize.x
		y=rpos.y
		y1=rpos.y+rsize.y
		pos=Vector2(randf_range(x,x1),randf_range(y,y1))
		for e in range(gpols.size()):
			finded=Geometry2D.is_point_in_polygon(pos,gpols[e])
			if finded:
				break
	return pos



#func boss_summon():
	#for e in cur_boss.keys():
		#var en=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
		#en.load_scene=load(gm.bosses[cur_boss[e].name].s)
		#var x=0
		#var y=0
		#var x1=0
		#var y1=0
		#var win=fnc.get_prkt_win()
		#x=rpos.x
		#x1=rpos.x+rsize.x
		#y=rpos.y
		#y1=rpos.y+rsize.y
		#var pos=Vector2(randf_range(x,x1),randf_range(y,y1))
		#var data={
			#"global_position":pos,
			#"dif":gm.game_prefs.dif,
			#"/boss_mark.bname":e
			#}
		#data.merge(gm.bosses[cur_boss[e].name].dificulty_lvl[gm.cur_dif].duplicate(true))
		#en.scene_data=data
		#en.global_position=pos
		##e.target_path=fnc.get_hero().get_path()
		#ememys_path.add_child(en)

func summon(enemys_count=0):
	for en in enemys_data:
		if en is enemy_data:
			if enemys_count==0:
				enemys_count=randi_range(en.count_min,en.count_max)
			
			for ec in range(enemys_count):
				if fnc._with_chance(en.percent):
					var e=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
					e.load_scene=en.enemy.instantiate()
					var pos=get_rand_pos()
					e.scene_data={
						"global_position":pos,
						"dif":gm.game_prefs.dif,
						"elite":fnc._with_chance(gm.game_prefs.elite_chance)
						}
					#e.target_path=fnc.get_hero().get_path()
					ememys_path.add_child(e)
					e.global_position=pos
#func _on_enemy_summon_timer_timeout():
	#if summoning:
		#summon()
		#var time=randf_range(spwn_time_periond_from,spwn_time_periond_to)
		#est.start(time)
	#
	#wave_count+=1
#func menu_exit():
	#get_tree().change_scene_to_file("res://menu.tscn")
#
#func boss_die(bname:int):
	#cur_boss[bname].die=true
	#if all_bosses_died():
		#at.start(10)
		#emit_signal("boss_fight_end")
