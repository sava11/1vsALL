class_name arena_action extends empty_node
@export var enemys:Array[empty_entety_data]
func get_summon_percents()->PackedFloat32Array:
	var perc:=PackedFloat32Array([])
	for e in enemys:
		perc.append(e.percent)
	return perc
func get_enemy_count(id:int):
	var ens=[]
	for e in enemys:
		if e is enemy_data:
			ens.append(fnc.rnd.randi_range(e.count_min,e.count_max))
	return ens
func get_summon_names()->PackedFloat32Array:
	var names=PackedStringArray([])
	for e in enemys:
		names.append(e.enemy_name)
	return names
