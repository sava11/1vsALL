extends Node2D
@export_range(0.001,999999) var time_periond_from:float=8
@export_range(0.001,999999) var time_periond_to:float=12
@export_range(1,999999) var enemys_count_from:int=8
@export_range(1,999999) var enemys_count_to:int=16
@export_range(1,100) var dif:int=1
@onready var est=$enemy_summon_timer

#func _physics_process(delta):
	#$cl/Control/stats/mny.text="money: "+str(fnc.get_hero().money)
	#$cl/Control/stats/exp.text="exp: "+str(fnc.get_hero().exp)

func summon():
	var enemys_count=randi_range(enemys_count_from,enemys_count_to)
	for ec in range(enemys_count):
		var e=preload("res://mats/enemys/e1/enemy.tscn").instantiate()
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

func summon1():
	var enemys_count=-1
	if $cl/Control/panel/cont/e/sb.value==-1:
		enemys_count=randi_range(enemys_count_from,enemys_count_to)
	else:
		enemys_count=$cl/Control/panel/cont/e/sb.value
	if $cl/Control/panel/cont/e/sb.value==0:
		for e in $world.get_children():
			if e != fnc.get_hero():
				e.queue_free()
	for ec in range(enemys_count):
		var e=preload("res://mats/enemys/e1/enemy.tscn").instantiate()
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
	summon()
	est.start(randf_range(time_periond_from,time_periond_to))
