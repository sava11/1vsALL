class_name level_template extends Node2D
@export var time:float
@export var cam:Camera2D

signal completed(res:bool)
func _ready():
	
	if cam!=null:
		var timer=Timer.new()
		timer.timeout.connect(Callable(self,"emit_signal").bind("completed",true))
		if time>0:
			timer.wait_time=time
			timer.autostart=true
		add_child(timer)
		var rsize=$arena_brd.size
		var rpos=$arena_brd.global_position
		var cm_brd=$cam_brd
		#print(cm_brd.position.x+cm_brd.size.x/fnc.get_prkt_win().x)
		cam.limit_left=cm_brd.position.x
		cam.limit_top=cm_brd.position.y
		cam.limit_bottom=cm_brd.position.y+cm_brd.size.y
		cam.limit_right=cm_brd.position.x+cm_brd.size.x
		fnc.get_hero().global_position=$pos.global_position
