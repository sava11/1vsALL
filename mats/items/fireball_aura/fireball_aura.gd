extends Node2D
@export_range(1,99999)var count:int=1
@export_range(0,99999) var time_period:float=2.0
@export_range(0,99999) var radius:float=50
var targets:Array=[]
var tars:Array=[]
func summon(custom_data:Dictionary):
	var e=preload("res://mats/enemys/smart_fireball/smart_fireball.tscn").instantiate()
	fnc.setter(e,custom_data)
	get_tree().current_scene.ememys_path.add_child(e)
	e.connect("deled",Callable(self,"minus_fb"))
	tars.append(e)
	b+=1
func get_empty_marks():
	var id=0
	for i in $fbs.get_children():
		for e in range(len(tars)):
			if tars[e].target==i:
				id=i.get_index()+1
	print(id)
	return id
func _ready():
	var ang=360.0/float(count)
	for e in range(count):
		var p=Marker2D.new()
		p.position=fnc.move(ang*e)*radius
		$fbs.add_child(p)
var time=0
var b=0
func _physics_process(delta):
	time+=delta
	rotation_degrees+=delta*75
	for i in range(len(tars)):
		if !is_instance_valid(tars[i]) or tars[i]==null:
			tars.remove_at(i)
	if time>=time_period and b<count:
		var bb=get_empty_marks()
		var t={
			"target":$fbs.get_child(bb),
			"acc_speed":700,
			"speed":350,
			"global_position":$fbs.get_child(bb).global_position,
			"collision_layer":1,
		}
		time=0
		summon(t)
func minus_fb():
	b-=1

