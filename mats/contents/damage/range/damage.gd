extends "res://mats/contents/damage/mele/damage.gd"
@export var load_scene:PackedScene
@export_range(1,9999) var count:int=1
@export_range(0,99999) var width:float=10.0
var trowed=false
func set_att_zone():
	var pol=PackedVector2Array([])
	pol.append(Vector2(0,width/2))
	pol.append(Vector2(attack_range,width/2))
	pol.append(Vector2(attack_range,-width/2))
	pol.append(Vector2(0,-width/2))
	$col.polygon=pol
func _what_draw(): 
	if get_parent().cur_anim==attack_anim_name and trowed==false:
		draw_line(Vector2.ZERO,Vector2(attack_range,0),Color(1.0,0,0,0.2),width,true)
func aiming():
	trowed=false
	var e=preload("res://mats/font/crit.tscn").instantiate()
	e.hide()
	e.texture=load(gm.images.icons.other.aim)
	e.global_position=global_position+Vector2(-e.size.x/2,-36)
	get_tree().current_scene.enemy_path.add_child(e)
func throw():
	var ang=float(360)/float(count)
	for e in range(count):
		var a=load_scene.instantiate()
		if !static_damage:
			a.damage=fnc._with_dific(randf_range(damage_from,damage_to),n.dif)
		else:
			a.damage=damage
		a.start_pos=global_position+fnc.move(global_rotation_degrees)*10
		a.global_rotation_degrees=ang*e+global_rotation_degrees-90
		a.speed=100
		a.sqrt=attack_range
		a.active=false
		get_tree().current_scene.enemy_path.add_child(a)
	trowed=true
