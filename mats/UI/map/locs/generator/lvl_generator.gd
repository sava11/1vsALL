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
var col=25
var row=25
var max_neighbors=[0,0.3,0.6,0.05,0.05]
var neighbors:=[]
var exceptions:=[]
func _pre_ready():
	#fnc.rnd.seed=0
	upd()
#создать возможномть телепорта к аренам которые не соеденены
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
		#exceptions.sort_custom((func(a, b):
			#var dist_a = a.distance_to(Vector2.ZERO)
			#var dist_b = b.distance_to(Vector2.ZERO)
			#return dist_a < dist_b))
	else:
		for e in get_children():
			e.free()
		#print("miner")
	gen_map_v1(exceptions,neighbors)
	emit_signal("map_generated")
func create_arena():
	var arena=arena_action.new()
	var enemys=(func():
		var enemys_path=["res://mats/enemys/e1/enemy.tscn","res://mats/enemys/e2/enemy.tscn",
		"res://mats/enemys/e3/enemy.tscn","res://mats/enemys/e4/enemy.tscn"]
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
	arena.enemys=enemys
	arena.enemys_count_min=fnc.rnd.randi_range(4,18)
	arena.enemys_count_max=fnc.rnd.randi_range(arena.enemys_count_min,18)
	return arena
func gen_map_v1(positions,neighbors):
	for e in positions:
		var scn:place=preload("res://mats/UI/map/place/place.tscn").instantiate()
		scn.position=e*48#16+32
		scn.choice_panel_showed.connect(Callable(self,"set_ingame_stats").bind(scn))
		var shop_chance=fnc._with_chance(0.1)
		if shop_chance:
			scn.shop=shop_action.new()
			if fnc._with_chance(0.25):
				scn.arena=create_arena()
		else:
			scn.arena=create_arena()
		add_child(scn)
	#print(get_child_count())
	#await get_tree().process_frame
	var mass:=get_children()
	var d:={}
	var temp_mass=mass.duplicate(true)
	
	for e in mass:
		temp_mass.sort_custom(Callable(func(a, b):
			var dist_a = a.global_position.distance_to(e.global_position)
			var dist_b = b.global_position.distance_to(e.global_position)
			return dist_a < dist_b and a!=e and b!=e))
		var local_angs=[]
		for k in range(neighbors[e.get_index()]):
			var ang=fnc.angle(temp_mass[k].global_position.direction_to(e.global_position))
			if local_angs.find(ang)==-1:
				local_angs.append(ang)
				e.neighbors.append(temp_mass[k])
				temp_mass[k].neighbors.append(e)
				if len(temp_mass[k].neighbors)<=3 and fnc._with_chance(0.075):
					temp_mass[k].secret=true
					#e.secret=true
		
				#if !dijkstra(temp_mass[k].get_index(),0,false):
					
				#await get_tree().process_frame
		#neighbors[e.get_index()]=len(e.neighbors)
	
	var bosses=["res://mats/enemys/b2/enemy.tscn","res://mats/enemys/b3/enemy.tscn",
	"res://mats/enemys/b4/enemy.tscn","res://mats/enemys/b5/enemy.tscn"]
	var place_with_bosses=[]
	while !bosses.is_empty():
		var bd=boss_data.new()
		bd.boss=bosses[0]
		bd.name=bosses[0]
		var filtered_mass=mass.duplicate(true).filter(
			(func(x): return x.secret==false and x.shop==null #and (place_with_bosses.is_empty() or place_with_bosses.filter((
				#func(y):
					#return dijkstra(x.get_index(),y.get_index(),false).size()<5)
				#).is_empty())
		))
		var node=filtered_mass[fnc.rnd.randi_range(0,len(filtered_mass)-1)]
		place_with_bosses.append(node)
		node.arena.enemys.append(bd)
		bosses.remove_at(0)
		
	#var e_id=0
	#while e_id<len(mass):
		#var e=mass[e_id]
		#var local_angs=[]
		#var k_id=0
		#while k_id<len(e.neighbors):
			#var k=e.neighbors[k_id]
			#var ang=fnc.angle(k.global_position.direction_to(e.global_position))
			#if local_angs.find(ang)==-1:
				#local_angs.append(ang)
			#else:
				#e.neighbors.remove_at(k_id)
				#k_id-=1
			#k_id+=1
		#e_id+=1
	#await get_tree().process_frame
	#print("start")
	#for e in get_children():
		#if dijkstra(e.get_index(),0,false).is_empty():
			#print(e.get_index())
			#e.get_node("nm").label_settings.font_color=Color(1,1,1,1)
	#print("ended")
	#var regions=region_detection()
	#print(regions)
	#for e in regions.keys():
		#if regions[e].centr
	#var glob_lengts=[]
	#for region in regions:
		#var r=region.duplicate(true)
		#var lengts=[]
		#for e in region:
			#r.sort_custom(Callable(func(a, b):
				#var dist_a = a.global_position.distance_to(e.global_position)
				#var dist_b = b.global_position.distance_to(e.global_position)
				#return dist_a < dist_b and a!=e and b!=e))
			#lengts.append([e,e.global_position.distance_to(r[0].global_position),r[0]])
		#lengts.sort_custom((func(x,y):return x[1]<y[1]))
		#glob_lengts.append(lengts[0])
		##print(lengts)
	#print(glob_lengts)
	#gm.save_file_data()

func set_ingame_stats(_place:place):
	if _place.ingame_statuses.is_empty():
		var a:Array[ingame_status]=[]
		var keys:Array=gm.player_data.stats.keys()
		for e in range(fnc._with_chance_ulti([0.05,0.4,0.35,0.2])):
			var i_s=ingame_status.new()
			i_s.status=keys.pick_random()
			var stat_data:Dictionary=gm.objs.stats[i_s.status]
			if stat_data.has("v") and stat_data.has("-v"):
				var v_keys:Array=stat_data.v.keys()
				var mv_keys:Array=stat_data["-v"].keys()
				var min=stat_data["-v"][mv_keys[0]].v.x
				var max=stat_data.v[v_keys[v_keys.size()-1]].v.y
				i_s.value=snapped(fnc.rnd.randf_range(min,max),0.001)
			else:
				i_s.value=fnc.rnd.randi_range(1,5)
			a.append(i_s)
		_place.ingame_statuses=a
