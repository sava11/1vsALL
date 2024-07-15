extends Area2D
@export var by_time:bool=false
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0
@export var autoset:bool=false
func _ready():
	if autoset:
		damage=fnc._with_dific(damage,get_tree().current_scene.dif)
		crit_damage=fnc._with_dific(crit_damage,get_tree().current_scene.dif)
		crit_chance=fnc._with_dific(crit_chance,get_tree().current_scene.dif)


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
	a_dmg.crit_chance=c_dmg
	damage=fnc._with_dific(damage,get_tree().current_scene.get("dif"))
	crit_damage=fnc._with_dific(crit_damage,get_tree().current_scene.get("dif"))
	a_dmg.collision_layer=6
	get_tree().current_scene.ememys_path.add_child.call_deferred(a_dmg)
	a_dmg.set_deferred("global_position",global_position)
	#+fnc.move(fnc.angle(target_position-global_position))*25
	
