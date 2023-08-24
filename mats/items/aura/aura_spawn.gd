extends Node2D
@export_range(0,99999) var sqrt:float=600
@export_range(0,99999) var spawn_time_period:float=5
@export_range(0,99999) var life_time_period:float=2
@export_range(0,99999) var hp:float=20
func set_stats(stats):
	spawn_time_period=stats["item_spawn_time"]
	life_time_period=stats["item_life_time"]
	hp=stats["hp"]
var timer:float=0
var stoped:bool=false
func _process(delta):
	timer+=delta*int(!stoped)
	if timer>=spawn_time_period:
		spawn_item()
		timer=0
	pass

func spawn_item():
	var s=preload("res://mats/items/aura/aura.tscn").instantiate()
	s.m_he=hp
	s.life_time_period=life_time_period
	s.position=Vector2.ZERO
	add_child(s)
	stoped=true
	get_parent().get_parent().get_node("hurt_box").set_deferred("monitoring",false)
	get_parent().get_parent().get_node("hurt_box").set_deferred("monitorable",false)

