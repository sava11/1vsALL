extends RigidBody2D
@export_group("parametrs")
@export var attack_range:float=80
@export var run_speed:float=80.0
@export var roll_speed:float=140.0
@export var desh_speed:float=200.0
@export_range(1,999999999) var life_points:float=10.0
@export_group("attack")
@export_range(1,999999999) var damage:float=2.0
@export_range(0,180) var angle_from:float=-45
@export_range(0,180) var angle_to:float=45
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
	at["parameters/conditions/die"]=false

var move_side=1
var mvd:Vector2=Vector2.RIGHT
var last_mvd:Vector2=Vector2(move_side,0)
enum{idle,move,rolling,attak_fast,die}
var state:int=0
func get_input():
	return Input.get_vector("left","right","up","down")

func _draw():
	draw_arc(Vector2.ZERO,30.0,deg_to_rad($hirtbox.rotation_degrees+35),deg_to_rad($hirtbox.rotation_degrees-35),30,Color(0,0,1.0,0.5),2,true)

func _process(_delta):
	queue_redraw()
	_upd_anim_params()
func _movement():
	if Input.get_action_strength("right") - Input.get_action_strength("left")!=0 :
		move_side=Input.get_action_strength("right") - Input.get_action_strength("left")
func _physics_process(_delta):
	roll=Input.is_action_just_pressed("roll")
	attak=false
	for e in fnc.get_world_node().get_children():
		if e!=self:
			var nearest_enemy_pos=e.global_position-global_position
			if fnc.angle(nearest_enemy_pos)>fnc.angle(last_mvd)+angle_from and fnc.angle(nearest_enemy_pos)<=fnc.angle(last_mvd)+angle_to:
				attak=fnc._sqrt(nearest_enemy_pos)<attack_range
	match state:
		idle:
			_movement()
			if get_input()==Vector2.ZERO:
				set_linear_velocity(Vector2.ZERO)
				if roll==true:
					state=rolling
				elif attak==true:
					state=attak_fast
			else:
				#s.stop()
				state=move
		move:
			_movement()
			mvd=get_input()
			if mvd!=Vector2.ZERO:
				last_mvd=mvd
				$hirtbox.rotation_degrees=fnc.angle(mvd)
				$body_hirtbox.rotation_degrees=fnc.angle(mvd)
				set_linear_velocity(mvd*run_speed)
				if roll==true:
					state=rolling
				elif attak==true:
					state=attak_fast
			else:
				state=idle
		attak_fast:
			mvd=get_input()
			if mvd!=Vector2.ZERO:
				last_mvd=mvd
				$hirtbox.rotation_degrees=fnc.angle(mvd)
				$body_hirtbox.rotation_degrees=fnc.angle(mvd)
				set_linear_velocity(mvd*run_speed)
			timer+=_delta
			if timer>=fast_attak_timer:
				timer=0
				_exit_from_anim()
		rolling:
			timer+=_delta
			set_linear_velocity(last_mvd*roll_speed)
			if timer>=roll_timer:
				timer=0
				hb.monitorable=true
				hb.monitoring=true
				_exit_from_anim()
		die:
			_freeze()
	print(state)
func _freeze():
	freeze=true
	set_linear_velocity(Vector2.ZERO)
func _unfreeze():
	print("unfrezd")
	freeze=false
func _exit_from_anim():
	_unfreeze()
	if state!=die:
		if get_input()==Vector2.ZERO:
			state=idle
		else:
			state=move
func _upd_anim_params():
	$pg.value=hb.he
	$pg.max_value=hb.m_he
	at["parameters/conditions/idle"]=state==idle
	at["parameters/conditions/is_run"]=state==move
	at["parameters/conditions/is_attaking"]=state==attak_fast
	at["parameters/conditions/is_roll"]=state==rolling
	at["parameters/conditions/die"]=state==die
	if move_side!=0:
		at["parameters/run/blend_position"]=move_side
		at["parameters/roll/blend_position"]=move_side
		at["parameters/idle/blend_position"]=move_side
		at["parameters/attak_fast/blend_position"]=move_side#-1+2*int(get_global_mouse_position().x>global_position.x)
		at["parameters/die/blend_position"]=move_side
func delete():
	pass

func _on_hurt_box_h_ch(v):
	if v>0:
		state=idle

func _on_hurt_box_no_he():
	if state!=die:
		state=die


func _on_get_money_area_area_entered(area):
	if area.type==0:
		money+=area.value
	if area.type==1:
		exp+=area.value
	area.queue_free()


func _on_hirtbox_body_entered(body):
	pass # Replace with function body.


func _on_hirtbox_body_exited(body):
	pass # Replace with function body.
