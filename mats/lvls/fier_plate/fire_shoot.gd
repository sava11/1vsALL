extends Area2D
@export var by_time:bool=false
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if a_dmg!=null and $cp.emitting==false:
		a_dmg.queue_free()
	pass


func _on_body_entered(body):
	$cp.emitting=true
	summon_cust_dmg(damage,crit_damage,crit_chance)
var a_dmg=null
func summon_cust_dmg(dmg,c_dmg,c_c):
	a_dmg=preload("res://mats/boxes/custom_dmg_area.tscn").instantiate()
	a_dmg.think(10)
	a_dmg.del_time=0
	a_dmg.damage=dmg
	a_dmg.crit_chance=c_dmg
	a_dmg.crit_damage=c_c
	a_dmg.collision_layer=6
	get_tree().current_scene.ememys_path.add_child.call_deferred(a_dmg)
	a_dmg.set_deferred("global_position",global_position)
	#+fnc.move(fnc.angle(target_position-global_position))*25
	
