@tool
class_name arena_action extends empty_node
@export var enemys:Array[empty_entety_data]
@export var spawning:bool=true
@export_range(1,99,1,"or_greater") var enemys_count_min:int=1
@export_range(1,99,1,"or_greater") var enemys_count_max:int=1
@export_range(1,99,1,"or_greater") var time_to_next_enemy_wave_min:float=10
@export_range(1,99,1,"or_greater") var time_to_next_enemy_wave_max:float=10

func get_named_summon_percents()->Dictionary:
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
						else: return items[en.name]})
	return items
func get_summon_percents()->PackedFloat32Array:
	var items:PackedFloat32Array=[]
	for en in enemys:
		if en is enemy_data:
			items.append(en.percent)
	return items
func get_summon_names()->PackedFloat32Array:
	var names=PackedStringArray([])
	for e in enemys:
		names.append(e.name)
	return names
func get_bosses()->Array[boss_data]:
	var ens:Array[boss_data] = []
	for en in enemys:
		if en is boss_data:
			ens.append(en)
	return ens
func has_bosses()->bool:
	for en in enemys:
		if en is boss_data:
			return true
	return false
func get_enemys()->Array[enemy_data]:
	var ens:Array[enemy_data] = []
	for en in enemys:
		if en is enemy_data:
			ens.append(en)
	return ens
func has_enemys()->bool:
	for en in enemys:
		if en is enemy_data:
			return true
	return false
func get_boss_by_name(name:String):
	for en in enemys:
		if en is boss_data and en.name==name:return en
