class_name level_template extends Node2D
signal time_event(event_id:int)
signal completed()
signal uncompleted()
@export var time:float
@export var time_events:PackedFloat32Array
@onready var cam:Camera2D=$ent/player/Camera2D
@export var enemys_data:arena_action
var rsize:Vector2
var rpos:Vector2
var timer:Timer
@onready var enemy_path=$ent/enemys
func start_timer(new_time:float):
	timer.wait_time=new_time
	timer.start()
func _ready():
	rsize=$arena_brd.size
	rpos=$arena_brd.global_position
	var cm_brd=$cam_brd
	var cam_scale:float=fnc.get_prkt_win().x/cm_brd.size.x
	if cam!=null:
		timer=Timer.new()
		timer.name="Timer"
		timer.one_shot=true
		timer.timeout.connect(Callable(self,"emit_signal").bind("completed"))
		$ent/player/hurt_box.no_he.connect(Callable(self,"emit_signal").bind("uncompleted"))
		add_child(timer)
		if time>0 and !enemys_data.has_bosses():
			start_timer(time)
		if cam_scale>1.25:
			cam.zoom=Vector2(cam_scale,cam_scale)
		cam.limit_left=cm_brd.position.x
		cam.limit_top=cm_brd.position.y
		cam.limit_bottom=cm_brd.position.y+cm_brd.size.y
		cam.limit_right=cm_brd.position.x+cm_brd.size.x
		summon_bosses()
var enemy_spawn_timer_temp:float=0
var next_enemy_spawn_timer_temp:float=0
var cur_step_time:float=0
var cur_step_id=0
func _physics_process(delta):
	cur_step_time+=delta
	if !time_events.is_empty() and cur_step_id<len(time_events) and cur_step_time>=time_events[cur_step_id]:
		emit_signal("time_event",cur_step_id)
		cur_step_time=0
		cur_step_id+=1
	if enemys_data!=null and enemys_data.spawning:
		enemy_spawn_timer_temp+=delta
		if next_enemy_spawn_timer_temp<=enemy_spawn_timer_temp:
			next_enemy_spawn_timer_temp=fnc.rnd.randi_range(enemys_data.time_to_next_enemy_wave_min,enemys_data.time_to_next_enemy_wave_max)
			if enemys_data.has_enemys():
				summon()
			enemy_spawn_timer_temp=0
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
func summon_bosses():
	if enemys_data!=null:
		var bosses=enemys_data.get_bosses()
		for b in bosses:
			var e=preload("res://mats/contents/summoner/summoner.tscn").instantiate()
			e.load_scene=load(b.boss)
			var pos=get_rand_pos()
			e.scene_data={
				"global_position":pos,
				"dif":gm.game_prefs.dif,
				"target":$ent/player,
				"elite":fnc._with_chance(gm.game_prefs.boss_elite_chance),
				"/boss_mark.scene_to_add":get_tree().current_scene.get_node("cl/game_ui/st"),
				"/boss_mark.scene_to_func":self,
				"/boss_mark.scene_func":"boss_die",
				"/boss_mark.bname":b.name
				}
			e.scene_data.merge(gm.bosses[b.name].dificulty_lvl[gm.cur_dif])
			#e.target_path=fnc.get_hero().get_path()
			enemy_path.add_child(e)
			e.global_position=pos
func summon(enemys_count=0):
	var items=enemys_data.get_summon_percents()
	if enemys_count==0:enemys_count=fnc.rnd.randi_range(enemys_data.enemys_count_min,enemys_data.enemys_count_max)
	for ec in range(enemys_count):
		var e=preload("res://mats/contents/summoner/summoner.tscn").instantiate()
		e.load_scene=load(enemys_data.enemys[fnc._with_chance_ulti(items)].enemy)
		var pos=get_rand_pos()
		e.scene_data={
			"global_position":pos,
			"dif":gm.game_prefs.dif,
			"target":$ent/player,
			"elite":fnc._with_chance(gm.game_prefs.elite_chance)
			}
		#e.target_path=fnc.get_hero().get_path()
		enemy_path.add_child(e)
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
func all_bosses_died():
	var res:int=0
	for b in enemys_data.get_bosses():
		res+=int(enemys_data.get_boss_by_name(b.name).die)
	return res==enemys_data.get_bosses().size()
func boss_die(bname:String):
	enemys_data.get_boss_by_name(bname).die=true
	if all_bosses_died():
		start_timer(10)
