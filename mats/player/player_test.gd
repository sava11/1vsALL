extends RigidBody2D
@export_group("parametrs")
@export var elite:bool=false
@export_range(0,100) var dif:float=1
@export var run_speed:float=25.0
@export var save_sqrt:float=-1
#enum statuses{a,d,i,r,rb,wait_anim}
@export var statuses:Dictionary={
	"a":"attack",
	"d":"death",
	"i":"idle",
	"r":"run",
	"ro":"roll",
	}
@export var attacks_chance_list={"attack":1.0}
@export_subgroup("life")
@export_range(1,999999999) var life_points_from:float=1.0
@export_range(1,999999999) var life_points_to:float=3.0
@export_subgroup("defence")
@export_range(1,999999999) var defence_from:float=0.5
@export_range(1,999999999) var defence_to:float=1.0
@export_group("attack1")
@export_range(0,99999) var attack1_time_period:float=2.0
@export var attack_range:float=30
@export_subgroup("damage")
@export_range(1,999999999) var damage_from:float=1.0
@export_range(1,999999999) var damage_to:float=2.0
@export var pos_from:float=-10
@export var pos_to:float=10
@export_range(-180,180) var angle_from:float=-45
@export_range(-180,180) var angle_to:float=45
@export_subgroup("crit_damage")
@export_range(1,999999999) var crit_damage_from:float=1.0
@export_range(1,999999999) var crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export_range(0.0,1.0) var crit_chance_from:float=0
@export_range(0.0,1.0) var crit_chance_to:float=0
@onready var hb=$hurt_box
enum custom_states{}
var attacks_times=[]
var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=mvd
var freezed_mvd:Vector2=mvd
var vec=Vector2.ZERO
var last_att_speed=0.3
var state="i"
@onready var cur_anim=statuses[state]
signal lvl_up(lvl:int)

var roll:bool=false
var attak:bool=false

#НЕ ЗАБЫВАЙ ПОСЛЕ ОБНОВЛЕНИЯ ВРЕМЕНИ АНИМАЦИИ ОБНАВЛЯТЬ ТАЙМЕРЫ!!!!!!!!!!!!!
var timer=0
var roll_timer=0
var cd={}
var add_stats={}

var exp:int=0
var lvl:int=0
# Called when the node enters the scene tree for the first time.
func merge_stats():
	for e in cd.stats.keys():
		if add_stats.get(e)!=null:
			cd.stats[e]=clamp(cd.stats[e]+add_stats[e],gm.objs.stats[e].min_v,999999999)
func test_chamber(anim_name:String,value:float):
	var timer=value
	for e in [anim_name]:
		var anim:Animation=$ap.get_animation(e)
		var tc=anim.get_track_count()
		var last_length=anim.length
		for tt in range(tc):
			for k in range(anim.track_get_key_count(tt)):
				var k1=anim.track_get_key_time(tt,k)/last_length
				#print(t," ",k)
				#print(anim.track_get_key_time(t,k),"-----")
				anim.track_set_key_time(tt,k,timer*k1)
		anim.length=timer
func get_sqrt(obj):
	return fnc._sqrt(obj.global_position-global_position)
var last_anim:int=0
func set_anim(anim_name:String,oneshoot:bool=false,changeing_pos:bool=true):
	var tname=""
	var anim=get_ang_move(rad_to_deg(last_mvd.angle())+180,90)*int(changeing_pos)+last_anim*int(!changeing_pos)
	last_anim=anim
	if anim==0:
		tname="_right"
	elif anim==2:
		tname="_left"
	elif anim==1:
		tname="_down"
	elif anim==3:
		tname="_up"
	if oneshoot:
		if $sp.animation!=anim_name+tname:
			$sp.animation=anim_name+tname
			$ap.play(anim_name)
			anim_finish=false
			cur_anim=anim_name
	else:
		$sp.animation=anim_name+tname
		$ap.play(anim_name)
		cur_anim=anim_name
		anim_finish=false
func get_input():
	return Input.get_vector("left","right","up","down")
func get_ang_move(angle:float,ex:float):
	var ang1=abs(ex)
	var le=int(360/ang1)
	var ang=int(abs(angle)+180+ang1/2)%360
	if ang>=0:for e in range(0,le):
		if ang>=e*ang1 and ang<(e+1)*ang1:
			return e
var anim_finish:bool=false
func _ready():
	connect("lvl_up",Callable(get_tree().current_scene,"add_to_lvl_queue"))
	cd=gm.player_data
	#cd=gm.objs["player"].duplicate()
	#cd.stats=gm.objs["player"].stats.duplicate()
	#cd.prefs=gm.objs["player"].prefs.duplicate()
	cd.prefs["cur_stm"]=cd.stats["max_stamina"]
	roll_timer=cd.prefs["roll_timer"]
	#var roll_t=$ap.get_animation("roll_up").length/roll_timer
	for e in ["roll"]:
		var anim:Animation=$ap.get_animation(e)
		var tc=anim.get_track_count()
		var last_length=anim.length
		anim.length=roll_timer
		for tt in range(tc):
			for k in range(anim.track_get_key_count(tt)):
				var k1=anim.track_get_key_time(tt,k)/last_length
				#print(t," ",k)
				#print(anim.track_get_key_time(t,k),"-----")
				anim.track_set_key_time(tt,k,roll_timer*k1)
	hb.monitorable=true
	hb.monitoring=true
	hb.s_m_h(cd.stats["hp"])
	hb.set_he(cd.prefs["cur_hp"])
	hb.s_m_d(cd.stats["def"])
	hb.set_def(cd.stats["def"])
	#$hirtbox.damage=damage
	
	set_att_zone()
func set_att_zone():
	var pol=PackedVector2Array([])
	var tang=abs(angle_from)+abs(angle_to)
	var dots=6
	var ang=tang/dots
	if pos_from==pos_to and pos_to==0:
		pol.append(Vector2.ZERO)
	else:
		pol.append(Vector2(0,pos_to))
		pol.append(Vector2(0,pos_from))
	for e in range(dots+1):
		pol.append(fnc.move(e*ang+angle_from)*attack_range)
	$hirtbox/col.polygon=pol
	$get_enemy_area/c.polygon=pol


func _draw():
	draw_arc(Vector2.ZERO,30.0,deg_to_rad($hirtbox.rotation_degrees+35),deg_to_rad($hirtbox.rotation_degrees-35),30,Color(0,0,1.0,0.5),2,true)
func _process(_delta):
	queue_redraw()
func _integrate_forces(st):
	#vec=st.get_linear_velocity()
	var step=st.get_step()
	pre_status(step)
	find_status(step)
	post_status()
	set_linear_velocity(vec)
	
	#set_anim()
func pre_status(_delta):
	$inv.rotation_degrees=fnc.angle(mvd)
	$pg.value=hb.he
	$pg.max_value=hb.m_he
	$get_enemy_area.rotation_degrees=fnc.angle(last_mvd)
	$hirtbox.rotation_degrees=$get_enemy_area.rotation_degrees
	$get_money_area/c.shape.radius=cd.stats.take_area
	if state!="d":
		if hb.m_he>hb.he:
			hb.set_he(hb.he+cd.stats["hp_regen"]*_delta)
		if exp >= cd.prefs["max_exp_start"]:
			lvl+=1
			exp-=cd.prefs["max_exp_start"]
			cd.prefs["max_exp_start"]=cd.prefs["max_exp_start"]*cd.prefs["max_exp_sc"]
			emit_signal("lvl_up",lvl)
		if cd.stats.hp!=hb.m_he:
			hb.s_m_h(cd.stats["hp"])
			hb.set_he(cd.stats["hp"])
		if cd.stats.def!=hb.m_def:
			hb.s_m_d(cd.stats["def"])
			hb.set_def(cd.stats["def"])
		if cd.stats["dmg"]!=$hirtbox.damage or cd.stats["crit_dmg"]!=$hirtbox.crit_damage or $hirtbox.crit_chance == cd.stats["%crit_dmg"]:
			$hirtbox.damage=cd.stats["dmg"]
			$hirtbox.crit_damage=cd.stats["crit_dmg"]
			$hirtbox.crit_chance=cd.stats["%crit_dmg"]
		#if cd.stats["+%att_speed"]!=last_att_speed:
		#	var v=cd.stats["+%att_speed"]-last_att_speed
		#	last_att_speed=cd.stats["+%att_speed"]
		#	test_chamber("attack",$ap.get_animation("attack").length-$ap.get_animation("attack").length*v)
	pass

func find_status(_delta:float):
	if state!="d":
		vec=get_linear_velocity()
		mvd=get_input()
		if state!="ro":
			if mvd!=Vector2.ZERO:
				last_mvd=mvd
				state="r"
			else:
				state="i"
		roll=Input.is_action_just_pressed("roll")
		attak=false
		if roll and cd.prefs["cur_stm"]>=cd.prefs["do_roll_cost"]:
			freezed_mvd=last_mvd
			state="ro"
			cd.prefs["cur_stm"]-=cd.prefs["do_roll_cost"]
		for e in bs:
			attak=true
		if attak and state!="ro":
			state="a"
		#print(state)
		if state=="a":
			cd.prefs["cur_stm"]=clamp(cd.prefs["cur_stm"]+_delta*(cd.stats["regen_stamina_point"]),0,cd.stats["max_stamina"])
			vec=vec.move_toward(mvd*(cd.stats["run_speed"]*cd.prefs["run_scale"]),_delta*cd.stats["run_speed"]*1000)
			set_anim(statuses[state])
		if state=="r":
			cd.prefs["cur_stm"]=clamp(cd.prefs["cur_stm"]+_delta*(cd.stats["regen_stamina_point"]),0,cd.stats["max_stamina"])
			vec=vec.move_toward(mvd*(cd.stats["run_speed"]*cd.prefs["run_scale"]),_delta*cd.stats["run_speed"]*1000)
			set_anim(statuses[state])
		if state=="ro":
			vec=freezed_mvd*cd.stats["roll_speed"]*cd.prefs["roll_scale"]
			timer+=_delta
			if timer>=roll_timer:
				timer=0
				hb.set_deferred("collision_mask", 2)
				state="i"
			set_anim(statuses[state])
		if state=="i":
			cd.prefs["cur_stm"]=clamp(cd.prefs["cur_stm"]+_delta*(cd.stats["regen_stamina_point"]),0,cd.stats["max_stamina"])
			vec=vec.move_toward(mvd*(cd.stats["run_speed"]*cd.prefs["run_scale"]),_delta*cd.stats["run_speed"]*1000)
			set_anim(statuses[state])
			vec=Vector2.ZERO
		new_dos(_delta)
	else:
		set_anim(statuses[state])
		vec=Vector2.ZERO
func new_dos(_delta:float):
	pass

func post_status():
	pass


func move(safe_velocity):
	if state=="r":
		set_linear_velocity(safe_velocity)
	else:
		set_linear_velocity(Vector2(0,0))

func _on_ap_animation_finished(anim_name):
	anim_finish=true



func delete():
	state="d"

func _on_hurt_box_h_ch(v):
	if v>0:
		pass
		#state=idle

func _on_hurt_box_no_he():
	set_deferred("freeze",true)
	set_linear_velocity(Vector2.ZERO)
	delete()


func _on_get_money_area_area_entered(area):
	if area.type==0:
		gm.player_data.prefs.money+=area.value
	if area.type==1:
		exp+=area.value
	area.queue_free()

var bs=[]
func _on_body_entered(b):
	if b!=self and b.is_in_group("border")==false:
		bs.append(b)


func _on_body_exited(b):
	if b!=self and b.is_in_group("border")==false:
		bs.remove_at(fnc.i_search(bs,b))


func _on_hurt_box_area_entered(area):
	cd.prefs["cur_hp"]=hb.he
	pass # Replace with function body.


