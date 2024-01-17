extends Node2D
@export var debug:bool=false
@export var gameplay:gm.gameplay_type=gm.cur_gameplay_type
@export_range(0.001,999999) var time_periond_from:float=8
@export_range(0.001,999999) var time_periond_to:float=12
@export_range(0.001,999999) var spwn_time_periond_from:float=8
@export_range(0.001,999999) var spwn_time_periond_to:float=12
@export_range(1,999999) var enemys_count_from:int=8
@export_range(1,999999) var enemys_count_to:int=16
@export_range(1,9999999) var waves:int
@export_range(0,9999999) var dif:float=0
@export_range(0,9999999) var lvl=0
@onready var est=$enemy_summon_timer
@onready var at=$arena_timer
@onready var ememys_path=$world/ent/enemys

@onready var rsize:Vector2
@onready var rpos:Vector2
func get_rand_pos_from(target_position:Vector2,distance:float):
	var c:NavigationMesh=$world.get_child(0).get_node("nav").navigation_polygon.get_navigation_mesh()
	var gpols=[]
	for e in range(c.get_polygon_count()):
		var pol:PackedVector2Array=PackedVector2Array([])
		for pid in c.get_polygon(e):
			pol.append(Vector2(c.vertices[pid].x,c.vertices[pid].z))
		gpols.append(pol)
	var pos=Vector2.ZERO
	var finded=false
	var ray=RayCast2D.new()
	ray.collision_mask=1
	ray.global_position=target_position
	$world.add_child(ray)
	var max_pos:Vector2
	while !finded :
		var rand_ang=fnc.rnd.randf_range(-180,180)
		ray.target_position = fnc.move(rand_ang)*distance
		ray.force_raycast_update()
		if ray.get_collider()!=null:
			pos = ray.get_collision_point()
		else:
			pos=ray.global_position+ray.target_position
		if ray.global_position.distance_to(max_pos)<ray.global_position.distance_to(pos):
			max_pos=pos
		for e in range(gpols.size()):
			finded=Geometry2D.is_point_in_polygon(pos,gpols[e]) and max_pos!=Vector2.ZERO or ray.get_collider()==null
			if finded:
				break
	ray.queue_free()
	return max_pos
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
var runned_arenas=0
var wave_count=1
var cur_map_id=0
var summoning:bool=true
var cur_boss:Dictionary={}
var cur_enemys:Dictionary={"sk_sw":1}
var exit:bool=false
var time_run=0

@onready var end_lvl=gm.maps.keys().max()
@onready var ivent_queue=PackedInt32Array([gm.ivents.stats_map])
signal end_arena()
signal boss_fight_end()
signal game_end()
func all_bosses_died():
	var res:int=0
	for b in cur_boss.keys():
		if cur_boss[b].die==true:
			res+=1
	return bool(int(res/cur_boss.size()))
func _ready():
	#gm.set_font(gm.cur_font,$cl/Control.theme)
	if !debug:
		if gameplay==gm.gameplay_type.clasic:
			show_lvls()
			#upd_lvl(lvl)
			$cl/map.upd_b_stats()
			connect("end_arena",Callable(fnc.get_hero(),"merge_stats"))
		if gameplay==gm.gameplay_type.bossrush:
			summoning=false
			bossrush_update()
			connect("end_arena",Callable(self,"bossrush_update"))
			end_lvl=len(gm.bossrush)
		if gameplay==gm.gameplay_type.train:
			lvl=-1
			$cl/map.name="del_map"
			$cl/del_map.queue_free()
			var m=preload("res://mats/UI/map/training_map.tscn").instantiate()
			m.name="map"
			$cl.add_child(m)
			$cl.move_child(m,1)
			$cl/Control/tip.show()
			$cl/map.upd_b_stats()
			show_lvls()
			connect("end_arena",Callable(fnc.get_hero(),"merge_stats"))
			
				
	#cur_enemys=gm.maps[lvl].enemys.duplicate()
	$cl/Control/die.hide()
func _physics_process(_delta):
	if Input.is_action_just_pressed("esc") and $world.visible:
		if get_tree().paused==false:
			get_tree().set_deferred("paused",true)
		else:
			get_tree().set_deferred("paused",false)
	
	#if gm.cur_font!=$cl/Control.theme.default_font["resource_name"]:
	#	gm.set_font(gm.cur_font,$cl/Control.theme)
	$cl/Control/status/money.text=str(fnc.get_hero().money)
	#$cl/Control/stats/vc/xp/pg.max_value=fnc.get_hero().cd.prefs["max_exp_start"]
	#$cl/Control/stats/vc/xp/pg.value=fnc.get_hero().exp
	#$cl/Control/stats/vc/xp/pg/t.text="\tlvl - "+str(fnc.get_hero().lvl)
	#$cl/Control/stats/vc/hp/pg/t.text="\t"+str(snapped(fnc.get_hero().hb.he,0.1))
	$cl/Control/status/hp.max_value=fnc.get_hero().hb.m_he
	$cl/Control/status/hp.value=fnc.get_hero().hb.he
	#$cl/Control/stats/vc/stamina/pg/t.text="\t"+str(snapped(fnc.get_hero().current_stamina,0.01))
	$cl/Control/status/stamina.max_value=fnc.get_hero().cd.stats.max_stamina
	$cl/Control/status/stamina.value=fnc.get_hero().current_stamina
	if int(at.time_left)>0:
		$cl/Control/time.show()
		$cl/Control/time.text="time: "+str(int(at.time_left))
	else:
		$cl/Control/time.hide()
	if (cur_boss.is_empty() or all_bosses_died()) and at.is_stopped() and at.autostart:
		var time=randf_range(time_periond_from,time_periond_to)
		at.start(time)
		if summoning:
			time=randf_range(spwn_time_periond_from,spwn_time_periond_to)
			est.start(time)
	if fnc.get_hero().state=="d":
		$cl/Control/die.show()
		mouse_massage()
		$cl/Control/status.hide()
		est.stop()
		at.stop()
		#for e in ememys_path.get_children():
			#e.queue_free()
	else:
		time_run+=_delta
	if $cl/map.visible==true and ememys_path.get_child_count()>0:
		for e in $cl/Control/bpg.get_children():
			e.queue_free()
		for e in ememys_path.get_children():
			e.queue_free()

func bossrush_update():
	if lvl+1<=end_lvl:#gm.maps.keys().max():
		cur_boss={}
		var ids=0
		for b in gm.bossrush[lvl].bosses:
			cur_boss.merge({ids:{"name":b,"die":false}})
			ids+=1
		var lvl_obj=null
		if cur_boss.is_empty():
			var t=gm.bossrush[lvl].locs.duplicate()
			var perc=[]
			for e in t.keys():
				perc.append(t[e]["%"])
			cur_map_id=fnc._with_chance_ulti(perc)
			lvl_obj=load(gm.bossrush[lvl].locs[cur_map_id].l).instantiate()
		else:
			var t=gm.bossrush[lvl]["boss_arena"].duplicate()
			var perc=[]
			for e in t.keys():
				perc.append(t[e]["%"])
			cur_map_id=fnc._with_chance_ulti(perc)
			lvl_obj=load(gm.bossrush[lvl].boss_arena[cur_map_id].l).instantiate()
		for n in fnc.get_world_node().get_children():
			if n.name!="ent":
				n.queue_free()
		$world.add_child(lvl_obj)
		$world.move_child(lvl_obj,0)
		rsize=lvl_obj.get_node("arena_brd").size
		rpos=lvl_obj.get_node("arena_brd").global_position
		var cm_brd=lvl_obj.get_node("cam_brd")
		$cam.limit_left=cm_brd.position.x
		$cam.limit_top=cm_brd.position.y
		$cam.limit_bottom=cm_brd.position.y+cm_brd.size.y
		$cam.limit_right=cm_brd.position.x+cm_brd.size.x
		fnc.get_hero().global_position=lvl_obj.get_node("pos").global_position
		#print(fnc.get_world_node().find_child(lvl.name))
		boss_summon()
		lvl+=1
	else:
		emit_signal("game_end")
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
		var data={
			"global_position":pos,
			"dif":dif,
			"/boss_mark.bname":e
			}
		data.merge(gm.bosses[cur_boss[e].name].dificulty_lvl[gm.cur_dif].duplicate(true))
		en.scene_data=data
		en.global_position=pos
		#e.target_path=fnc.get_hero().get_path()
		ememys_path.add_child(en)

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
		e.scene_data={
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
	
	wave_count+=1
func menu_exit():
	sls.sd.dinamic={}
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
	if lvl<end_lvl and (gameplay==gm.gameplay_type.clasic or gameplay==gm.gameplay_type.train):
		show_lvls()
		$cl/map.upd_stats()
		
	emit_signal("end_arena")
	runned_arenas+=1
	#else:
	#	pass
	if exit:
		new_lvl()
		exit=false
	
	#get_tree().change_scene_to_file("res://mats/UI/map/panel.tscn")
func new_lvl():
	if lvl+1<=end_lvl and gameplay!=gm.gameplay_type.train:#gm.maps.keys().max():
		lvl+=1
		upd_lvl(lvl)
		$cl/map.upd_b_stats()
	else:
		emit_signal("game_end")
func stop():
	est.stop()
	at.stop()
func start_game():
	upd_lvl(lvl)
	dif+=0.15
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
		start_sound_think()
		stop_sound_fight()
		$world.hide()
		$cl/Control.hide()
		$cl/map.show()
	else:
		stop_sound_think()
		start_sound_fight()
		$world.show()
		$cl/Control.show()
		$cl/map.hide()
	get_tree().set_deferred("paused",b)
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
	$world.add_child(lvl)
	$world.move_child(lvl,0)
	rsize=lvl.get_node("arena_brd").size
	rpos=lvl.get_node("arena_brd").global_position
	var cm_brd=lvl.get_node("cam_brd")
	$cam.limit_left=cm_brd.position.x
	$cam.limit_top=cm_brd.position.y
	$cam.limit_bottom=cm_brd.position.y+cm_brd.size.y
	$cam.limit_right=cm_brd.position.x+cm_brd.size.x
	fnc.get_hero().global_position=lvl.get_node("pos").global_position
	#print(fnc.get_world_node().find_child(lvl.name))


func _on_boss_fight_end():
	#print("GJJHHK")
	pass # Replace with function body.
func mouse_massage():
	var m=$cl/Control/die/mm
	var f=m.get_theme_font("normal_font").get_string_size(m.text).x
	m.global_position.x=-f/2+$cl/Control.size.x/2
	var hours=0
	var mins=0
	var sec=int(time_run)
	if sec>=60:
		mins=(sec-sec%60)/60
		sec-=mins*60
	if mins>=60:
		hours=(mins-mins%60)/60
		sec-=mins*60
	$cl/Control/die/Panel/results/time.text=tr("RUN_END_TIME")+": "+str(hours)+":"+str(mins)+":"+str(sec)
	$cl/Control/die/Panel/results/lvl.text=tr("RUN_END_LVL")+": "+str(lvl)
	$cl/Control/die/Panel/results/arenas.text=tr("END_RUN_ARENAS")+": "+str(runned_arenas)
	
	$cl/Control/game_end/vc/c/Panel/results/time.text=tr("RUN_END_TIME")+": "+str(hours)+":"+str(mins)+":"+str(sec)
	$cl/Control/game_end/vc/c/Panel/results/lvl.text=tr("RUN_END_LVL")+": "+str(lvl)
	$cl/Control/game_end/vc/c/Panel/results/arenas.text=tr("END_RUN_ARENAS")+": "+str(runned_arenas)
	
func _on_end_arena():pass
	#sls.save_data()


func _on_game_end():
	get_tree().set_deferred("paused",true)
	$cl/Control/game_end.show()


func _on_b_button_down():
	$cl/Control/game_end/vc/c/Panel/b.hide()
	$cl/Control/game_end/ap.play("end")

func start_sound_fight():
	$asp_fight.play()
func stop_sound_fight():
	$asp_fight.stop()
func start_sound_think():
	$asp_think.play()
func stop_sound_think():
	$asp_think.stop()
func _on_asp_think_finished():
	pass # Replace with function body.


func _on_asp_fight_finished():
	pass # Replace with function body.
