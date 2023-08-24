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
@onready var lvl_path=$world/lvl
var wave_count=1
var cur_map_id=0
var cur_boss:PackedStringArray
var cur_enemys:PackedStringArray=[]
var boss_killed=false
@onready var ivent_queue=PackedInt32Array([gm.ivents.stats_map])
signal end_arena()


func _ready():
	$cam.limit_left=$Panel.position.x
	$cam.limit_top=$Panel.position.y
	$cam.limit_bottom=$Panel.position.y+$Panel.size.y
	$cam.limit_right=$Panel.position.x+$Panel.size.x
	if debug==false:
		show_lvls()
		upd_lvl(lvl)
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
	$cl/Control/stats/vc/xp/pg/t.text="\tlvl - "+str(fnc.get_hero().lvl)
	$cl/Control/stats/vc/hp.text="hp:"+str(snapped(fnc.get_hero().hb.he,0.1))+"\t/"+str(fnc.get_hero().hb.m_he)
	$cl/Control/stats/vc/stamina/pg/t.text="\t"+str(snapped(fnc.get_hero().current_stamina,0.01))
	$cl/Control/stats/vc/stamina/pg.max_value=fnc.get_hero().cd.stats.max_stamina
	$cl/Control/stats/vc/stamina/pg.value=fnc.get_hero().current_stamina
	$cl/Control/waves.text="wave survived: "+str(wave_count-1)
		
	if int(at.time_left)>0:
		$cl/Control/time.show()
		$cl/Control/time.text="time: "+str(int(at.time_left)+1)
	else:
		$cl/Control/time.hide()
	if cur_boss.is_empty() and at.is_stopped() and at.autostart:
		var time=randf_range(time_periond_from,time_periond_to)
		at.start(time)
		time=randf_range(spwn_time_periond_from,spwn_time_periond_to)
		est.start(time)
	if fnc.get_hero().die==true:
		$cl/Control/die.show()
		est.stop()
		at.stop()
		for e in ememys_path.get_children():
			e.queue_free()
	if $cl/map.visible==true and ememys_path.get_child_count()>0:
		for e in ememys_path.get_children():
			e.queue_free()
	
func boss_summon():
	var rsize=Vector2(576,256)
	var rpos=Vector2(-288,-128)
	var e=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
	e.load_scene=load(cur_boss[0])
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
	e.scene_params={
		"global_position":pos,
		"dif":dif,
		}
	e.global_position=pos
	#e.target_path=fnc.get_hero().get_path()
	ememys_path.add_child(e)
var hlvls_queue=PackedInt32Array([])
func add_to_lvl_queue(hlvl:int):
	hlvls_queue.append(hlvl)


func summon(enemys_count=0):
	if enemys_count==0:enemys_count=randi_range(enemys_count_from,enemys_count_to)
	var rsize=Vector2(576,256)
	var rpos=Vector2(-288,-128)
	for ec in range(enemys_count):
		var e=preload("res://mats/enemys/summoner/summoner.tscn").instantiate()
		var ens=cur_enemys.duplicate()
		e.load_scene=load(gm.enemys[ens[gm.rnd.randi_range(0,ens.size()-1)]].s)
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
		e.scene_params={
			"global_position":pos,
			"dif":dif,
			}
		e.global_position=pos
		#e.target_path=fnc.get_hero().get_path()
		ememys_path.add_child(e)
func _on_enemy_summon_timer_timeout():
	if !cur_boss.is_empty():
		est.stop()
		at.stop()
		boss_summon()
		at.time_left=0
	else:
		summon()
		var time=randf_range(spwn_time_periond_from,spwn_time_periond_to)
		est.start(time)
	dif+=0.1
	wave_count+=1
func menu_exit():
	get_tree().change_scene_to_file("res://menu.tscn")

func boss_die():
	at.start(10)
	cur_boss.clear()
	boss_killed=true
func _on_arena_timer_timeout():
	stop()
	for e in ememys_path.get_children():
		e.queue_free()
	#if hlvls_queue.is_empty():
	show_lvls()
	emit_signal("end_arena")
	#else:
	#	pass
	if boss_killed:
		lvl=clamp(lvl+1,0,gm.maps.keys().max())
		upd_lvl(lvl)
		boss_killed=false
	else:
		$cl/map.upd_stats()
	#get_tree().change_scene_to_file("res://mats/UI/map/panel.tscn")
	
func stop():
	est.stop()
	at.stop()
func start_game():
	if !cur_boss.is_empty():
		est.stop()
		at.stop()
		boss_summon()
	else:
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
	#cur_map_id=gm.fnc.randi_range(0,len(gm.maps[lvl_id].locs.keys())-1)
	var lvl=load(gm.maps[lvl_id].locs[cur_map_id].l).instantiate()
	enemys_count_from=snapped(gm.maps[lvl_id].ecount.x,1)
	enemys_count_to=snapped(gm.maps[lvl_id].ecount.y,1)
	for n in fnc.get_world_node().get_children():
		if n.name!="ent":
			n.queue_free()
	fnc.get_world_node().add_child.call_deferred(lvl)
	fnc.get_world_node().move_child.call_deferred(lvl,0)
	$cl/map.upd_b_stats()
	#print(fnc.get_world_node().find_child(lvl.name))
