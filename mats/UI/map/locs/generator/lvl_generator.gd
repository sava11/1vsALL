extends "res://mats/UI/map/locs/map_aditional_script_tamplate.gd"
signal map_generated
func data_to_save():
	var pos=[]
	for e in exceptions:
		pos.append([e.x,e.y])
	return {"n":neighbors.duplicate(),"p":pos}

func data_to_load(n:Dictionary):
	neighbors=n.n
	exceptions=[]
	for e in n.p:
		exceptions.append(Vector2(e[0],e[1]))
var col=15
var row=10
var max_neighbors=[0,0.4,0.3,0.05,0.05]
var neighbors:=[]
var exceptions:=[]
func _pre_ready():
	upd()

func upd():
	if exceptions.is_empty() and neighbors.is_empty():
		var place_count=fnc.rnd.randi_range(col*row/2,col*row)
		#for e in range(col*row):
			#if fnc._with_chance(0.75):
				#neighbors.append(clamp(fnc._with_chance_ulti(max_neighbors),0,col*row-1)+1)
				#exceptions.append(Vector2(e%col,(e-e%col)/col))
		for e in range(place_count):
			var x=fnc.rnd.randi_range(0,col)
			var y=fnc.rnd.randi_range(0,row)
			while fnc.i_search(exceptions,Vector2(x,y))!=-1:
				x=fnc.rnd.randi_range(0,col)
				y=fnc.rnd.randi_range(0,row)
			neighbors.append(clamp(fnc._with_chance_ulti(max_neighbors),0,place_count-1)+1)
			exceptions.append(Vector2(x,y))
		exceptions.sort_custom((func(a, b):
			var dist_a = a.distance_to(Vector2.ZERO)
			var dist_b = b.distance_to(Vector2.ZERO)
			return dist_a < dist_b))
	else:
		for e in get_children():
			e.free()
		#print("miner")
	gen_map_v1(exceptions,neighbors)
	emit_signal("map_generated")
func create_arena():
	var arena=arena_action.new()
	arena.enemys=(func():
		var enemys_path=["res://mats/enemys/e1/enemy.tscn","res://mats/enemys/e2/enemy.tscn","res://mats/enemys/e3/enemy.tscn","res://mats/enemys/e4/enemy.tscn"]
		var select_enemys_percents=[0.5,0.2,0.4,0.1]
		var count_enemys_percents=[0.1,0.3,0.2,0.2]
		var ens:Array[empty_entety_data]=[]
		var count=fnc._with_chance_ulti([0.05,0.5,0.4,0.1])+1
		for i in range(count):
			var enemy=enemy_data.new()
			var e_p_id=fnc._with_chance_ulti(select_enemys_percents)
			enemy.enemy=enemys_path[e_p_id]
			enemys_path.remove_at(e_p_id)
			select_enemys_percents.remove_at(e_p_id)
			ens.append(enemy)
		return ens).call()
	arena.enemys_count_min=fnc.rnd.randi_range(4,18)
	arena.enemys_count_max=fnc.rnd.randi_range(arena.enemys_count_min,18)
	return arena
func gen_map_v1(positions,neighbors):
	for e in positions:
		var scn=preload("res://mats/UI/map/place/place.tscn").instantiate()
		scn.position=e*48#16+32
		add_child(scn)
	#print(get_child_count())
	await get_tree().process_frame
	var mass:=get_children()
	var d:={}
	var temp_mass=mass.duplicate(true)
	
	for e in mass:
		var shop_chance=fnc._with_chance(0.1)
		if shop_chance:
			e.shop=shop_action.new()
			if fnc._with_chance(0.25):
				e.arena=create_arena()
		else:
			e.arena=create_arena()
		temp_mass.sort_custom(Callable(func(a, b):
			var dist_a = a.global_position.distance_to(e.global_position)
			var dist_b = b.global_position.distance_to(e.global_position)
			return dist_a < dist_b and a!=e and b!=e))
		var local_angs=[]
		for k in range(neighbors[e.get_index()]):
			var ang=fnc.angle(temp_mass[k].global_position.direction_to(e.global_position))
			if e!=temp_mass[k] and local_angs.find(ang)==-1:
				local_angs.append(ang)
				e.neighbors.append(temp_mass[k])
				temp_mass[k].neighbors.append(e)
				if len(temp_mass[k].neighbors)<=3 and fnc._with_chance(0.075):
					#e.secret=true
					temp_mass[k].secret=true
				#await get_tree().process_frame
		#neighbors[e.get_index()]=len(e.neighbors)
	var bosses=["res://mats/enemys/b2/enemy.tscn","res://mats/enemys/b3/enemy.tscn","res://mats/enemys/b4/enemy.tscn","res://mats/enemys/b5/enemy.tscn"]
	var selected_bosses=[]
	for e in range(len(bosses)):
		pass
	var e_id=0
	while e_id<len(mass):
		var e=mass[e_id]
		var local_angs=[]
		var k_id=0
		while k_id<len(e.neighbors):
			var k=e.neighbors[k_id]
			var ang=fnc.angle(k.global_position.direction_to(e.global_position))
			if local_angs.find(ang)==-1:
				local_angs.append(ang)
			else:
				e.neighbors.remove_at(k_id)
				k_id-=1
			k_id+=1
		e_id+=1
	#await get_tree().process_frame
	#for e in get_children():
		#if dijkstra(e.get_index(),0,false).is_empty():
			#print(e.get_index())
	#print("ended")
	gm.save_file_data()


func _on_player_position_changed(_place:place):
	pass
