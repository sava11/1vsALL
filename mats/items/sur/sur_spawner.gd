extends Node2D
@export_range(0,99999) var sqrt:float=600
@export_range(0,99999) var spawn_time_period:float=5
@export_range(0,99999) var damage:float=1
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0
@export_range(0,99999) var counts:float=6
func set_stats(stats):
	spawn_time_period=stats["item_spawn_time"]
	damage=stats["dmg"]
	crit_damage=stats["crit_dmg"]
	crit_chance=stats["%crit_dmg"]
	counts=stats["item_count"]
# Called when the node enters the scene tree for the first time.
func _ready():
	$t.start(spawn_time_period)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_sur(count:int):
	var ang=360.0/float(count)
	for e in range(count):
		var s=preload("res://mats/items/sur/sur/sur.tscn").instantiate()
		s.speed=150
		s.global_position=global_position
		s.global_rotation_degrees=ang*e+fnc.angle(fnc.get_hero().last_mvd)
		s.start_pos=global_position
		#s.get_node("s").position.y-=10
		s.damage=damage
		s.crit_chance=crit_chance
		s.crit_damage=crit_damage
		s.sqrt=sqrt
		get_tree().current_scene.ememys_path.add_child(s)
	
func _on_timer_timeout():
	spawn_sur(counts)
	$t.start(spawn_time_period)
