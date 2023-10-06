extends Node2D
@export var debug:bool=false
@export_range(0.001,999999) var time_periond_from:float=8
@export_range(0.001,999999) var time_periond_to:float=12
@export_range(0.001,999999) var spwn_time_periond_from:float=8
@export_range(0.001,999999) var spwn_time_periond_to:float=12
@export_range(1,999999) var enemys_count_from:int=8
@export_range(1,999999) var enemys_count_to:int=16
@export_range(1,9999999) var waves:int
@export_range(0,9999999) var dif:float=1
@export_range(0,9999999) var lvl=0
@onready var est=$enemy_summon_timer
@onready var at=$arena_timer
@onready var ememys_path=$world/ent/enemys

@onready var rsize = $area.size
@onready var rpos=$area.global_position
func get_rand_pos():
	var c:NavigationMesh=$world.get_child(0).get_node("nav").navigation_polygon.get_navigation_mesh()
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

var wave_count=1
var cur_map_id=0
var summoning:bool=true
var cur_boss:Dictionary={}
var cur_enemys:Dictionary={"sk_sw":1}
var exit:bool=false
var time_run=0
@onready var ivent_queue=PackedInt32Array([gm.ivents.stats_map])
signal end_arena()
signal boss_fight_end()
func all_bosses_died():
	var res:int=0
	for b in cur_boss.keys():
		if cur_boss[b].die==true:
			res+=1
	return bool(int(res/cur_boss.size()))
func _ready():
	
	$cam.limit_left=$cam_bord.position.x
	$cam.limit_top=$cam_bord.position.y
	$cam.limit_bottom=$cam_bord.position.y+$cam_bord.size.y
	$cam.limit_right=$cam_bord.position.x+$cam_bord.size.x
	if debug==false:
		show_lvls()
		#upd_lvl(lvl)
		$cl/map.upd_b_stats()
	#cur_enemys=gm.maps[lvl].enemys.duplicate()
	connect("end_arena",Callable(fnc.get_hero(),"merge_stats"))
	$cl/Control/die.hide()
func un_pause():
	if get_tree().paused==false:
		get_tree().set_deferred("paused",true)
	elif get_tree().paused==true:
		get_tree().set_deferred("paused",false)
func _process(_delta):
	var paused=Input.is_action_just_pressed("esc")
	if paused:un_pause()
func _physics_process(_delta):
	$cl/Control/stats/vc/mny_cont/mny.txt=str(fnc.get_hero().money)
	$cl/Control/stats/vc/xp/pg.max_value=fnc.get_hero().cd.prefs["max_exp_start"]
	$cl/Control/stats/vc/xp/pg.value=fnc.get_hero().exp
	#$cl/Control/stats/vc/xp/pg/t.text="\tlvl - "+str(fnc.get_hero().lvl)
	$cl/Control/stats/vc/hp/pg/t.text="\t"+str(snapped(fnc.get_hero().hb.he,0.1))
	$cl/Control/stats/vc/hp/pg.max_value=fnc.get_hero().hb.m_he
	$cl/Control/stats/vc/hp/pg.value=snapped(fnc.get_hero().hb.he,0.1)
	$cl/Control/stats/vc/stamina/pg/t.text="\t"+str(snapped(fnc.get_hero().current_stamina,0.01))
	$cl/Control/stats/vc/stamina/pg.max_value=fnc.get_hero().cd.stats.max_stamina
	$cl/Control/stats/vc/stamina/pg.value=fnc.get_hero().current_stamina
		
	if int(at.time_left)>0:
		$cl/Control/time.show()
		$cl/Control/time.text="time: "+str(int(at.time_left)+1)
	else:
		$cl/Control/time.hide()
	if (cur_boss.is_empty() or all_bosses_died()) and at.is_stopped() and at.autostart:
		var time=randf_range(time_periond_from,time_periond_to)
		at.start(time)
		time=randf_range(spwn_time_periond_from,spwn_time_periond_to)
		est.start(time)
	if fnc.get_hero().state=="d":
		$cl/Control/die.show()
		mouse_massage()
		$cl/Control/stats.hide()
		est.stop()
		at.stop()
		for e in ememys_path.get_children():
			e.queue_free()
	else:
		time_run+=_delta
	if $cl/map.visible==true and ememys_path.get_child_count()>0:
		for e in $cl/Control/bpg.get_children():
			e.queue_free()
		for e in ememys_path.get_children():
			e.queue_free()
	
func boss_summon():
	for e in cur_boss.keys():
		var en=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
		en.load_scene=load(gm.bosses[cur_boss[e].name].s)
		var x=0
		var y=0
		var x1=0
		var y1=0
		var win=fnc.get_prkt_win()
		x=rpos.x
		x1=rpos.x+rsize.x
		y=rpos.y
		y1=rpos.y+rsize.y
		var pos=Vector2(randf_range(x,x1),randf_range(y,y1))
		en.scene_params={
			"global_position":pos,
			"dif":dif,
			"bname":e
			}
		en.global_position=pos
		#e.target_path=fnc.get_hero().get_path()
		ememys_path.add_child(en)
var hlvls_queue=PackedInt32Array([])
func add_to_lvl_queue(hlvl:int):
	hlvls_queue.append(hlvl)


func summon(enemys_count=0):
	if enemys_count==0:enemys_count=randi_range(enemys_count_from,enemys_count_to)
	
	for ec in range(enemys_count):
		var e=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
		var ens=cur_enemys.duplicate()
		var itms_v=[]
		var itms=[]
		for en in ens.keys():
			itms_v.append(ens[en])
		for en in ens.keys():
			itms.append(en)
		e.load_scene=load(gm.enemys[itms[fnc._with_chance_ulti(itms_v)]].s)
		var pos=get_rand_pos()
		e.scene_params={
			"global_position":pos,
			"dif":dif,
			"elite":fnc._with_chance(0.01)
			}
		#e.target_path=fnc.get_hero().get_path()
		ememys_path.add_child(e)
		e.global_position=pos
func _on_enemy_summon_timer_timeout():
	if summoning:
		summon()
		var time=randf_range(spwn_time_periond_from,spwn_time_periond_to)
		est.start(time)
	dif+=0.1
	wave_count+=1
func menu_exit():
	get_tree().change_scene_to_file("res://menu.tscn")

func boss_die(bname:int):
	
	cur_boss[bname].die=true
	if all_bosses_died():
		at.start(10)
		emit_signal("boss_fight_end")
func _on_arena_timer_timeout():
	stop()
	for e in ememys_path.get_children():
		e.queue_free()
	#if hlvls_queue.is_empty():
	show_lvls()
	emit_signal("end_arena")
	#else:
	#	pass
	if exit:
		new_lvl()
		exit=false
	$cl/map.upd_stats()
	#get_tree().change_scene_to_file("res://mats/UI/map/panel.tscn")
func new_lvl():
	lvl=clamp(lvl+1,0,gm.maps.keys().max())
	upd_lvl(lvl)
func stop():
	est.stop()
	at.stop()
func start_game():
	if !cur_boss.is_empty():
		est.stop()
		at.stop()
		boss_summon()
	if summoning and cur_boss.is_empty():
		summon()
		var time=randf_range(spwn_time_periond_from,spwn_time_periond_to)
		est.start(time)
		time=randf_range(time_periond_from,time_periond_to)
		at.start(time)
func start_waves():
	var time=randf_range(spwn_time_periond_from,spwn_time_periond_to)
	est.start(time)
func show_lvls(b:bool=true):
	if b==true:
		$world.hide()
		$cl/Control.hide()
		$cl/map.show()
	else:
		$world.show()
		$cl/Control.show()
		$cl/map.hide()
func upd_lvl(lvl_id):
	var lvl=null
	if cur_boss.is_empty():
		var t=gm.maps[lvl_id].locs.duplicate()
		var perc=[]
		for e in t.keys():
			perc.append(t[e]["%"])
		cur_map_id=fnc._with_chance_ulti(perc)
		lvl=load(gm.maps[lvl_id].locs[cur_map_id].l).instantiate()
	else:
		var t=gm.maps[lvl_id]["boss_arena"].duplicate()
		var perc=[]
		for e in t.keys():
			perc.append(t[e]["%"])
		cur_map_id=fnc._with_chance_ulti(perc)
		lvl=load(gm.maps[lvl_id].boss_arena[cur_map_id].l).instantiate()
	#cur_map_id=gm.rnd.randi_range(0,len(gm.maps[lvl_id].locs.keys())-1)
	enemys_count_from=snapped(gm.maps[lvl_id].ecount.x,1)
	enemys_count_to=snapped(gm.maps[lvl_id].ecount.y,1)
	for n in fnc.get_world_node().get_children():
		if n.name!="ent":
			n.queue_free()
	fnc.get_world_node().add_child.call_deferred(lvl)
	fnc.get_world_node().move_child.call_deferred(lvl,0)
	$cl/map.upd_b_stats()
	#print(fnc.get_world_node().find_child(lvl.name))


func _on_boss_fight_end():
	#print("GJJHHK")
	pass # Replace with function body.
func mouse_massage():
	var m=$cl/Control/die/mm
	var f=m.get_theme_font("normal_font").get_string_size(m.text).x
	m.global_position.x=-f/2+$cl/Control.size.x/2
	$cl/Control/die/results/time.text=tr("RUN_END_TIME")+": "+str( snapped(time_run,0.1))
	$cl/Control/die/results/lvl.text=tr("RUN_END_LVL")+": "+str(snapped(lvl,1))
