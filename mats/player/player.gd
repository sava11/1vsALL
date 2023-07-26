extends RigidBody2D
@export_group("parametrs")
@export var attack_range:float=40
@export var run_speed:float=80.0
@export var roll_speed:float=140.0
@export var desh_speed:float=200.0
@export_range(1,999999999) var life_points:float=10.0
@export_group("attack")
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
@onready var roll_timer=0.6
@onready var fast_attak_timer=0.44
var money=0
var exp=0
var lvl=0
# Called when the node enters the scene tree for the first time.
func _ready():
	hb.monitorable=true
	hb.monitoring=true
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	$hirtbox.damage=damage
	at.active=true
	at["parameters/conditions/death"]=false
	var pol=PackedVector2Array([])
	var tang=abs(angle_from)+abs(angle_to)
	var dots=6
	var ang=tang/dots
	print(ang)
	if pos_from==pos_to and pos_to==0:
		pol.append(Vector2.ZERO)
	else:
		pol.append(Vector2(0,pos_to))
		pol.append(Vector2(0,pos_from))
	for e in range(dots+1):
		pol.append(fnc.move(e*ang+angle_from)*attack_range)
	$hirtbox/col.polygon=pol

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
func _physics_process(_delta):
	mvd=get_input()
	if mvd!=Vector2.ZERO:
		last_mvd=mvd
	roll=Input.is_action_just_pressed("roll")
	attak=false
	for e in fnc.get_world_node().get_children():
		if e!=self:
			var nearest_enemy_pos=e.global_position-global_position
			if fnc.angle(nearest_enemy_pos)>$hirtbox.rotation_degrees+angle_from and fnc.angle(nearest_enemy_pos)<=$hirtbox.rotation_degrees+angle_to:
				attak=fnc._sqrt(nearest_enemy_pos)<=attack_range
	
	
	
	if roll:
		freezed_mvd=last_mvd
		rolling=true
	if rolling:
		vec=freezed_mvd*roll_speed
		timer+=_delta
		if timer>=roll_timer:
			timer=0
			hb.monitorable=true
			hb.monitoring=true
			_exit_from_anim()
			rolling=false
	else:
		vec=mvd*run_speed
		$hirtbox.rotation_degrees=fnc.angle(last_mvd)
	set_linear_velocity(vec)
	#print(state)
func _freeze():
	freeze=true
	set_linear_velocity(Vector2.ZERO)
func _unfreeze():
	#print("unfrezd")
	freeze=false
func _exit_from_anim():
	_unfreeze()
func _upd_anim_params():
	$pg.value=hb.he
	$pg.max_value=hb.m_he
	at["parameters/conditions/idle"]=mvd==Vector2.ZERO and roll==false and rolling==false
	at["parameters/conditions/run"]=mvd!=Vector2.ZERO and roll==false and rolling==false
	at["parameters/conditions/attack1"]=attak
	at["parameters/conditions/roll"]=rolling
	at["parameters/conditions/death"]=false
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
	pass


func _on_get_money_area_area_entered(area):
	if area.type==0:
		money+=area.value
	if area.type==1:
		exp+=area.value
	area.queue_free()

var bs=[]
func _on_hirtbox_body_entered(b):
	bs.append(b)


func _on_hirtbox_body_exited(b):
	bs.remove_at(fnc.i_search(bs,b))
