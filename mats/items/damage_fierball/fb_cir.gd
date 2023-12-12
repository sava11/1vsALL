extends "res://mats/contents/summon/summon.gd"
@export_enum("sm","au") var fb_type:int
@export_group("fireballs")
@export var auto_set:bool=false
@export_range(1,99999) var speed:float=100
@export_range(1,99999) var acc_speed:float=100
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0
@export var targets:Array
var data={
		"speed":speed,
		"acc_speed":acc_speed,
		"damage":damage,
		"crit_damage":crit_damage,
		"crit_chance":crit_chance,
	}
var time=0
func _physics_process(delta):
	time+=delta
	print(time)
	if time>=time_period:
		var t=custom_data.duplicate(true)
		t.merge({
			"target":fnc.rnd.randi_range(0,len(targets)-1),
			"global_position":fnc.move(fnc.rnd.randf_range(0,360))*custom_summon_radius
		})
		custom_data=t
		print("ff")
		time=0
		summon()
