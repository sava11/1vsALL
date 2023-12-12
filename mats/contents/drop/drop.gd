extends Node

@export_range(0,1) var money_drop_percent:float=0.1
@export_range(0,999999) var money_drop_from:int=1
@export_range(0,999999) var money_drop_to:int=2

func drop(dif=get_tree().current_scene.dif):
	if fnc._with_chance(money_drop_percent):
		var v=preload("res://mats/ingame_value/value.tscn").instantiate()
		v.value=fnc._with_dific(randi_range(money_drop_from,money_drop_to),dif)
		get_parent().get_parent().add_child.call_deferred(v)
		v.set_deferred("global_position",get_parent().global_position)
