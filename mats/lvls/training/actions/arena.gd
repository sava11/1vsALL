class_name arena_action extends empty_node
@export var enemys:Array[enemy_data]
@export_range(0,9999,1,"or_greater","suffix:sec") var time:float=60
func get_summon_percents()->PackedFloat32Array:
	var perc:=PackedFloat32Array([])
	for e in enemys:
		perc.append(e.percent)
	return perc
func get_summon_names()->PackedFloat32Array:
	var names=PackedStringArray([])
	for e in enemys:
		names.append(e.enemy_name)
	return names
