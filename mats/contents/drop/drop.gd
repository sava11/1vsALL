extends Node

@export_range(0,1) var money_drop_percent:float=0.1
@export_range(0,999999) var money_drop_from:float=0.8
@export_range(0,999999) var money_drop_to:float=0.9

func drop(dif=gm.game_prefs.dif):
	if fnc._with_chance(money_drop_percent):
		var v=preload("res://mats/ingame_value/value.tscn").instantiate()
		v.value=clampi(int(fnc._with_dific(randf_range(money_drop_from,money_drop_to),dif)),1,9999999)
		get_parent().get_parent().add_child.call_deferred(v)
		v.set_deferred("global_position",get_parent().global_position)
