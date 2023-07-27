extends Node2D
@export_range(0.001,999999) var time_periond_from:float=8
@export_range(0.001,999999) var time_periond_to:float=12
@export_range(1,999999) var enemys_count_from:int=8
@export_range(1,999999) var enemys_count_to:int=16
@export_range(0,100) var dif:float=1
@onready var est=$enemy_summon_timer
var wave_count=0
func _ready():
	$cl/Control/die.hide()
func _physics_process(delta):
	
	$cl/Control/stats/vc/mny.text="money: "+str(fnc.get_hero().money)
	$cl/Control/stats/vc/exp.text="exp: "+str(fnc.get_hero().exp)
	$cl/Control/stats/vc/hp.text="hp:"+str(snapped(fnc.get_hero().hb.he,0.1))+"\t/"+str(fnc.get_hero().hb.m_he)
	$cl/Control/stats/vc/rolls.text="rolls: "+str(int(fnc.get_hero().current_roll_points))+"/"+str(fnc.get_hero().max_roll_points)
	$cl/Control/waves.text="wave survived: "+str(wave_count)
	if fnc.get_hero().die==true:
		$cl/Control/die.show()
		est.stop()
		for e in $world.get_children():
			if e is enemy:
				e._on_hurt_box_no_he()


func summon():
	var enemys_count=randi_range(enemys_count_from,enemys_count_to)
	for ec in range(enemys_count):
		var e=preload("res://mats/enemys/e1/enemy1.tscn").instantiate()
		e.dif=dif
		var x=0
		var y=0
		var x1=0
		var y1=0
		var win=fnc.get_prkt_win()
		if randi_range(0,1)==0:
			x=-win.x/2+e.image_height
			x1=-win.x/2+fnc.get_hero().run_speed*1.2+e.image_height
		else:
			x=win.x/2-e.image_height
			x1=win.x/2-fnc.get_hero().run_speed*1.2-e.image_height
		if randi_range(0,1)==0:
			y=-win.y/2+e.image_height
			y1=-win.y/2+fnc.get_hero().run_speed*1.2+e.image_height
		else:
			y=win.y/2-e.image_height
			y1=win.y/2-fnc.get_hero().run_speed*1.2-e.image_height
		e.global_position=Vector2(randf_range(x,x1),randf_range(y,y1))+fnc.get_camera().global_position
		#e.target_path=fnc.get_hero().get_path()
		$world.add_child(e)

func summon1():
	var enemys_count=-1
	if $cl/Control/panel/cont/e/sb.value==-1:
		enemys_count=randi_range(enemys_count_from,enemys_count_to)
	else:
		enemys_count=$cl/Control/panel/cont/e/sb.value
	if $cl/Control/panel/cont/e/sb.value==0:
		for e in $world.get_children():
			if e is enemy:
				e._on_hurt_box_no_he()
	for ec in range(enemys_count):
		var e=preload("res://mats/enemys/e1/enemy1.tscn").instantiate()
		var x=0
		var y=0
		var x1=0
		var y1=0
		var win=fnc.get_prkt_win()
		if randi_range(0,1)==0:
			x=-win.x/2
			x1=-win.x/2-fnc.get_hero().run_speed*1.2-e.image_height
		else:
			x=win.x/2
			x1=win.x/2+fnc.get_hero().run_speed*1.2+e.image_height
		if randi_range(0,1)==0:
			y=-win.y/2
			y1=-win.y/2-fnc.get_hero().run_speed*1.2-e.image_height
		else:
			y=win.y/2
			y1=win.y/2+fnc.get_hero().run_speed*1.2+e.image_height
		e.global_position=Vector2(randf_range(x,x1),randf_range(y,y1))+fnc.get_camera().global_position
		e.target_path=fnc.get_hero().get_path()
		$world.add_child(e)
func _on_enemy_summon_timer_timeout():
	wave_count+=1
	summon()
	dif+=0.01
	var time=randf_range(time_periond_from,time_periond_to)
	est.start(time+time*dif)


func _on_button_button_down():
	get_tree().change_scene_to_file("res://menu.tscn")
