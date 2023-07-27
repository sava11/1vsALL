extends RigidBody2D
@export var player_type:gm.player_types
@export_group("parametrs")
@export_range(0,99999) var max_roll_points:int=3
@export_range(0.001,99999) var add_roll_point_time:float=1.2
@export var run_speed:float=80.0
@export var roll_speed:float=200.0
@export_range(1,999999999) var life_points:float=10.0
@export_group("attack")
@export var attack_range:float=40
@export_range(1,999999999) var damage:float=2.0
@export var pos_from:float=-10
@export var pos_to:float=10
@export_range(-180,180) var angle_from:float=-45
@export_range(-180,180) var angle_to:float=45
@onready var at=$at
@onready var hb=$hurt_box
var roll:bool=false
var attak:bool=false

#НЕ ЗАБЫВАЙ ПОСЛЕ ОБНОВЛЕНИЯ ВРЕМЕНИ АНИМАЦИИ ОБНАВЛЯТЬ ТАЙМЕРЫ!!!!!!!!!!!!!
var timer=0
var roll_timer=0
var money=0
var exp=0
var lvl=0
var current_roll_points=max_roll_points
var cd={}
# Called when the node enters the scene tree for the first time.
func _ready():
	cd=gm.objs["player"][player_type].duplicate()
	roll_timer=cd["roll_timer"]
	var roll_t=$ap.get_animation("roll_up").length/cd["roll_timer"]
	for e in ["roll_up","roll_down","roll_left","roll_right"]:
		var anim:Animation=$ap.get_animation(e)
		anim.length=cd["roll_timer"]
		var tc=anim.get_track_count()-1
		for t in range(tc):
			for k in range(anim.track_get_key_count(t)):
				anim.track_set_key_time(t,k,anim.track_get_key_time(t,k)*roll_t)
	run_speed=cd["run_speed"]
	roll_speed=cd["roll_speed"]
	life_points=cd["hp"]
	hb.monitorable=true
	hb.monitoring=true
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	hb.s_m_d(cd["def"])
	hb.set_def(cd["def"])
	$hirtbox.damage=damage
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
func _physics_process(_delta):
	if die==false:
		mvd=get_input()
		if mvd!=Vector2.ZERO:
			last_mvd=mvd
		roll=Input.is_action_just_pressed("roll")
		attak=bs!=[]
		if roll and int(current_roll_points)>0:
			freezed_mvd=last_mvd
			rolling=true
			current_roll_points-=1
		if rolling:
			vec=freezed_mvd*roll_speed
			timer+=_delta
			if timer>=roll_timer:
				timer=0
				hb.monitorable=true
				hb.monitoring=true
				rolling=false
		else:
			current_roll_points=clamp(current_roll_points+_delta*(1/add_roll_point_time),0,max_roll_points)
			vec=mvd*run_speed
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
	if b!=self and b!=get_tree().current_scene.get_node("border"):
		bs.append(b)


func _on_body_exited(b):
	if b!=self and b!=get_tree().current_scene.get_node("border"):
		bs.remove_at(fnc.i_search(bs,b))
