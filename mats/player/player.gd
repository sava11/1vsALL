extends RigidBody2D
@export_group("parametrs")
#@export_range(0,99999) var max_roll_points:int=3
#@export_range(0.001,99999) var add_roll_point_time:float=1.2
#@export var run_speed:float=80.0
#@export var roll_speed:float=200.0
#@export_range(1,999999999) var life_points:float=10.0
@export_group("attack")
@export var attack_range:float=40
#@export_range(1,999999999) var damage:float=2.0
@export var pos_from:float=-10
@export var pos_to:float=10
@export_range(-180,180) var angle_from:float=-45
@export_range(-180,180) var angle_to:float=45
@onready var at=$at
@onready var hb=$hurt_box
signal lvl_up(lvl:int)

var roll:bool=false
var attak:bool=false

#НЕ ЗАБЫВАЙ ПОСЛЕ ОБНОВЛЕНИЯ ВРЕМЕНИ АНИМАЦИИ ОБНАВЛЯТЬ ТАЙМЕРЫ!!!!!!!!!!!!!
var timer=0
var roll_timer=0
var current_stamina=0
var cd={}
var inv={}
var add_stats={}
var money:int=0
var exp:int=0
var lvl:int=0
#var inventORI={}#"name":{"stat":value}
# Called when the node enters the scene tree for the first time.
func merge_stats():
	for e in cd.stats.keys():
		if add_stats.get(e)!=null:
			cd.stats[e]+=add_stats[e]
func test_chamber(anim_name:String,value:float):
	var timer=value
	for e in [anim_name+"_up",anim_name+"_down",anim_name+"_left",anim_name+"_right"]:
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
func _ready():
	connect("lvl_up",Callable(get_tree().current_scene,"add_to_lvl_queue"))
	cd=gm.objs["player"][gm.player_type].duplicate()
	cd.stats=gm.objs["player"][gm.player_type].stats.duplicate()
	cd.prefs=gm.objs["player"][gm.player_type].prefs.duplicate()
	current_stamina=cd.stats["max_stamina"]
	roll_timer=cd.prefs["roll_timer"]
	#var roll_t=$ap.get_animation("roll_up").length/roll_timer
	for e in ["roll_left","roll_up","roll_down","roll_right"]:
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
	at.active=true
	at["parameters/conditions/death"]=false
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

#enum{idle,move,rolling,attak_fast,die}
#var state:int=0
func get_input():
	return Input.get_vector("left","right","up","down")

func _draw():
	draw_arc(Vector2.ZERO,30.0,deg_to_rad($hirtbox.rotation_degrees+35),deg_to_rad($hirtbox.rotation_degrees-35),30,Color(0,0,1.0,0.5),2,true)

func _process(_delta):
	queue_redraw()
	_upd_anim_params()



var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=mvd
var freezed_mvd:Vector2=mvd
var vec=Vector2.ZERO
var rolling=false
var die=false
var last_att_speed=0.3
func _physics_process(_delta):
	if die==false:
		if hb.m_he>hb.he:
			hb.set_he(hb.he+cd.stats["hp_rgen"]*_delta)
		if exp >= cd.prefs["max_exp_start"]:
			lvl+=1
			exp-=cd.prefs["max_exp_start"]
			cd.prefs["max_exp_start"]=cd.prefs["max_exp_start"]*cd.prefs["max_exp_sc"]
			emit_signal("lvl_up",lvl)
		$get_money_area/c.shape.radius=cd.stats.take_area
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
		if cd.stats["+%att_speed"]!=last_att_speed:
			var v=cd.stats["+%att_speed"]-last_att_speed
			last_att_speed=cd.stats["+%att_speed"]
			test_chamber("attak_fast",$ap.get_animation("attak_fast_up").length-$ap.get_animation("attak_fast_up").length*v)

		vec=get_linear_velocity()
		mvd=get_input()
		if mvd!=Vector2.ZERO and rolling!=true:
			last_mvd=mvd
		roll=Input.is_action_just_pressed("roll")
		attak=bs!=[]
		if roll and int(current_stamina)>0:
			freezed_mvd=last_mvd
			rolling=true
			current_stamina-=cd.stats["do_roll_cost"]
		if rolling:
			vec=freezed_mvd*cd.prefs["roll_speed"]*cd.prefs["roll_scale"]
			timer+=_delta
			if timer>=roll_timer:
				timer=0
				hb.monitorable=true
				hb.monitoring=true
				rolling=false
		else:
			current_stamina=clamp(current_stamina+_delta*(cd.stats["regen_stamina_point"]),0,cd.stats["max_stamina"])
			vec=vec.move_toward(mvd*(cd.prefs["run_speed"]*cd.prefs["run_scale"]+cd.prefs["run_speed"]*cd.stats["%sp"]),_delta*cd.prefs["run_speed"]*1000)
			$hirtbox.rotation_degrees=fnc.angle(last_mvd)
			$get_enemy_area/c.rotation_degrees=$hirtbox.rotation_degrees
		set_linear_velocity(vec)
	#print(state)
func _upd_anim_params():
	$pg.value=hb.he
	$pg.max_value=hb.m_he
	at["parameters/conditions/idle"]=mvd==Vector2.ZERO and roll==false and rolling==false
	at["parameters/conditions/run"]=mvd!=Vector2.ZERO and roll==false and rolling==false
	at["parameters/conditions/attack1"]=attak
	at["parameters/conditions/roll"]=rolling
	at["parameters/conditions/death"]=die
	at["parameters/run/blend_position"]=last_mvd
	at["parameters/roll/blend_position"]=last_mvd
	at["parameters/idle/blend_position"]=last_mvd
	at["parameters/attack1/blend_position"]=last_mvd#-1+2*int(get_global_mouse_position().x>global_position.x)
	at["parameters/death/blend_position"]=last_mvd
func delete():
	pass

func _on_hurt_box_h_ch(v):
	if v>0:
		pass
		#state=idle

func _on_hurt_box_no_he():
	set_deferred("freeze",true)
	set_linear_velocity(Vector2.ZERO)
	die=true


func _on_get_money_area_area_entered(area):
	if area.type==0:
		money+=area.value
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
