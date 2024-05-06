class_name arena_action extends empty_node
@export var enemys:Array[empty_entety_data]
@export_range(1,99,1,"or_greater") var enemys_count_min:int=1:
	set(v):
		if v>enemys_count_max:
			enemys_count_min=enemys_count_max
		else:
			enemys_count_min=v
	get:
		return enemys_count_min
@export_range(1,99,1,"or_greater") var enemys_count_max:int=1: 
	set(v):
		if v<enemys_count_min:
			enemys_count_max=enemys_count_min
		else:
			enemys_count_max=v
	get:
		return enemys_count_max
@export_range(1,99,1,"or_greater") var time_to_next_enemy_wave_min:int=10:
	set(v):
		if v>time_to_next_enemy_wave_max:
			time_to_next_enemy_wave_min=time_to_next_enemy_wave_max
		else:
			time_to_next_enemy_wave_min=v
	get:
		return time_to_next_enemy_wave_min
@export_range(1,99,1,"or_greater") var time_to_next_enemy_wave_max:int=10: 
	set(v):
		if v<time_to_next_enemy_wave_min:
			time_to_next_enemy_wave_max=time_to_next_enemy_wave_min
		else:
			time_to_next_enemy_wave_max=v
	get:
		return enemys_count_max
func get_summon_percents()->Dictionary:
	var items={}
	for en in enemys:
		if en is enemy_data:
			var id=enemys.find(en)
			if !items.has(id):
				items.merge({id:en.percent})
			else:
				items.merge({
				id:
					func(): 
						if en.percent>items[id]:
							return en.percent 
						else: return items[en.enemy_name]})
	return items
func get_summon_names()->PackedFloat32Array:
	var names=PackedStringArray([])
	for e in enemys:
		names.append(e.enemy_name)
	return names
