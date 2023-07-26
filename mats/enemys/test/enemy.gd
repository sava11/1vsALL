class_name skeletV1 extends RigidBody2D
@export_group("parametrs")
@export var image_height:int=100
@export var run_speed:float=40.0
@export_range(1,999999999) var life_points:float=6.0
@export_group("drop")
@export_range(1,99999) var money_dropped_from:int=1
@export_range(1,99999) var money_dropped_to:int=4
@export_range(0,99999) var exp_dropped_from:int=0
@export_range(0,99999) var exp_dropped_to:int=10
@export_group("argesive")
@export var target_path:NodePath
@export var attack_range:float=20.0
@export_range(1,999999999) var damage:float=1.0
@onready var at=$at
@onready var hb=$hurt_box
var attak:bool=false
@onready var target=get_node_or_null(target_path)


#НЕ ЗАБЫВАЙ ПОСЛЕ ОБНОВЛЕНИЯ ВРЕМЕНИ АНИМАЦИИ ОБНАВЛЯТЬ ТАЙМЕРЫ!!!!!!!!!!!!!
var timer=0
@onready var fast_attak_timer=1


# Called when the node enters the scene tree for the first time.
func _ready():
	hb.s_m_h(life_points)
	hb.set_he(life_points)
	$hirtbox.damage=damage
	at.active=true
	at["parameters/conditions/die"]=false
var mvd:Vector2=Vector2.ZERO
var last_mvd:Vector2=Vector2.ZERO
enum{idle,move,attak_fast,die}
var state:int=0
var move_side=0
var ang=360/8
func get_input():
	return fnc.move(fnc.get_ang_move(fnc.angle(target.global_position-global_position)+180,ang)*ang)

var vec_to_player:Vector2=Vector2.ZERO
func _movement():
	move_side=get_input().x

func _draw():
	draw_arc(Vector2.ZERO,attack_range,deg_to_rad($hirtbox.rotation_degrees+35),deg_to_rad($hirtbox.rotation_degrees-35),30,Color(1.0,0,0,0.5),2,true)

func _process(_delta):
	queue_redraw()
	_upd_anim_params()

func _physics_process(_delta):
	vec_to_player=target.global_position-global_position
	attak=fnc._sqrt(vec_to_player)<attack_range
	match state:
		idle:
			_movement()
			if get_input()==Vector2.ZERO:
				if attak==true:
					$hirtbox.rotation_degrees=fnc.angle(get_input())
					set_linear_velocity(Vector2.ZERO)
				else:
					_freeze()
					state=attak_fast
			else:
				state=move
		move:
			_movement()
			mvd=get_input()
			last_mvd=mvd
			if mvd!=Vector2.ZERO:
				if attak!=true:
					$hirtbox.rotation_degrees=fnc.angle(mvd)
					set_linear_velocity(mvd*run_speed)
				else:
					_freeze()
					state=attak_fast
			else:
				state=idle
		attak_fast:
			timer+=_delta
			if timer>=fast_attak_timer:
				timer=0
				_exit_from_anim()
		die:
			_freeze()
func _freeze():
	freeze=true
	set_linear_velocity(Vector2.ZERO)
func _unfreeze():
	freeze=false
func _exit_from_anim():
	_unfreeze()
	if state!=die:
		if get_input()==Vector2.ZERO:
			state=idle
		else:
			state=move
func _upd_anim_params():
	at["parameters/conditions/idle"]=state==idle
	at["parameters/conditions/is_run"]=state==move
	at["parameters/conditions/is_attaking"]=state==attak_fast
	at["parameters/conditions/die"]=state==die
	if move_side!=0:
		at["parameters/run/blend_position"]=move_side
		at["parameters/idle/blend_position"]=move_side
		at["parameters/attak_fast/blend_position"]=move_side
		at["parameters/death/blend_position"]=move_side

func delete():
	#var money=preload("res://mats/ingame_value/value.tscn").instantiate()
	#money.global_position=global_position
	#money.type=0
	#money.value=randi_range(money_dropped_from,money_dropped_to)
	#fnc.get_world_node().add_child.call_deferred(money)
	queue_free()
	


func _on_hurt_box_no_he():
	
	state=die
