extends "res://mats/boxes/custom_dmg_area.gd"
@export_range(0.001,999999)var width:float=5
@export var count:int=1
@export_range(0.001,60) var zone_angle:float=30
@export_range(0.001,999999) var radius:float=10
@export var del_sqrt=100
@export var sqrt_per_sec:float=10.0
func pre_ready():
	var pols=PackedVector2Array([])
	var ang=zone_angle/float(count)
	for e in range(count+1):
		pols.append(fnc.move(ang*e)*radius)
	for e in range(count+1):
		pols.append(fnc.move(ang*(count)-ang*e)*(radius-width))
	think(pols)
	
func past_ready():
	print(damage," ",crit_damage," ",crit_chance)
func _process(delta):
	queue_redraw()
	obj.scale.x+=sqrt_per_sec*delta
	obj.scale.y+=sqrt_per_sec*delta
	if radius*obj.scale.x>del_sqrt:
		queue_free()


func _on_body_entered(body):
	queue_free()

