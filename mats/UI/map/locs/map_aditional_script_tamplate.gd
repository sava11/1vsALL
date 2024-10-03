class_name Game_map extends Control
signal map_generated
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)
signal player_position_changed(place:Place)
@export var regions:Array[Region]
func get_region_where_boss_scene_path_is(scn_path:String)->int:
	for i in range(regions.size()):
		var e:Region=regions[i]
		if e.boss_path==scn_path:
			return i
	return -1
func get_regions_colors()->Array[Color]:
	var clrs:Array[Color]=[]
	for e in regions:
		clrs.append(e.color)
	return clrs
func get_regions_positions()->Array[Vector2]:
	var clrs:Array[Vector2]=[]
	for e in regions:
		clrs.append(e.pos)
	return clrs
@export var curve_dificulty:Curve
func _get_dif()->float:
	return curve_dificulty.sample(_get_process_ratio())
func get_dif(value:float)->float:
	var max_dif:float=0
	for e in get_children():
		max_dif+=e.local_difficulty_add_step
	return curve_dificulty.sample(value/max_dif)
func _get_process_ratio():
	var max_dif:float=0
	var cur_dif:float=0
	for e in get_children():
		max_dif+=e.local_difficulty_add_step
		if e.runned:cur_dif+=e.local_difficulty_add_step
	if max_dif>0:
		return cur_dif/max_dif
	else:return 0
func data_to_save()->Dictionary:return{}
func save_data():
	var pos=""
	if current_pos!=null:
		pos=str(current_pos.get_path())
	var d={
			"cur_pos":pos,
		}
	d.merge(data_to_save(),true)
	return {str(get_path()):d}
func data_to_load(n:Dictionary)->void:pass
func load_data(n:Dictionary):
	current_pos=get_node(n["cur_pos"])
	data_to_load(n)
@export var current_pos:Place
@export var level_container:Node2D
var map_is_generated:=false
func set_cur_pos(pos:Place):
	var t=get_children()
	if pos!=null:
		current_pos=pos
	else:
		var ps=pos
		while ps==null or ps.shop or (ps.arena!=null and ps.arena.has_bosses()):
			ps=t[fnc.rnd.randi_range(0,get_child_count()-1)]
		current_pos=ps
	current_pos.runned=true
	#var nearst:Array[place]=[]
	#t.sort_custom(
			#(Callable(func(a, b):
				#var dist_a = a.global_position.distance_to(current_pos.global_position)
				#var dist_b = b.global_position.distance_to(current_pos.global_position)
				#return dist_a < dist_b)
		#))
	#var count=8
	#if t.size()<8:
		#count-=t.size()
	#for e in range(count):
		#nearst.append(t[e])
	for cur_place in t:
		cur_place.player_here=cur_place==current_pos
		#var corned_=is_on_corner(nearst,cur_place)
		#if corned_:
			#cur_place.neighbors.append(current_pos)
			#current_pos.neighbors.append(cur_place)
			#cur_place.choice_play.connect((
				#func():
					#var _lvl_:level_template=preload("res://mats/lvls/lvl1/lvl1_2.tscn").instantiate()
					#_lvl_.time=30
					#var ed=arena_action.new()
					#var enemys_path=["res://mats/enemys/e1/enemy.tscn","res://mats/enemys/e2/enemy.tscn","res://mats/enemys/e5/enemy.tscn"]
					#var select_enemys_percents=[0.2,0.3,0.5]
					#var count_enemys_percents=[0.45,0.35,0.2]
					#var enemys:Array[empty_entety_data]=[]
					#var count=fnc._with_chance_ulti([0.3,0.5,0.2])+1
					#for i in range(count):
						#var enemy=enemy_data.new()
						#var e_p_id=fnc._with_chance_ulti(select_enemys_percents)
						#enemy.enemy=enemys_path[e_p_id]
						#enemys_path.remove_at(e_p_id)
						#select_enemys_percents.remove_at(e_p_id)
						#enemys.append(enemy)
					#ed.enemys=enemys
					#_lvl_.enemys_data=ed
					#
			#))
		set_ingame_stats(cur_place)
		cur_place.get_node("btn").disabled=!(cur_place.runned or current_pos.neighbors.find(cur_place)>-1) #and !corned_
	gm.save_file_data()
	emit_signal("player_position_changed",current_pos)
func _pre_ready():
	map_is_generated=true
	emit_signal("map_generated")
func _post_ready():pass
func _ready():
	get_tree().set_deferred("paused",false)
	gm.set_dark(true)
	level_container=get_node_or_null("../../../../../../world")
	var map=get_node_or_null("../../../../")
	var t1=Time.get_time_dict_from_system()
	_pre_ready()
	if !map_is_generated:
		await map_generated
	add_to_group("SN")
	connect("save_data_changed",Callable(gm,"_save_node"))
	connect("_load_data",Callable(gm,"_load_node"))
	if !gm.sn.has(str(get_path())):
		emit_signal("save_data_changed",save_data())
	else:
		emit_signal("_load_data",self,str(get_path()))
	if map!=null:
		connect("player_position_changed",Callable(map,"set_cur_pos"))
		await get_tree().process_frame
		await get_tree().process_frame
	#print("start setting signals")
	for e in get_children():
		if is_instance_valid(e):
			e.runned_changed.connect(Callable(func(res):if res and current_pos!=e:set_cur_pos(e)))
			e.get_node("btn").button_down.connect(
				Callable(
					func(b:Place):
						if b.runned and !dijkstra(current_pos.get_index(),b.get_index()).is_empty():
							current_pos.player_here=false
							set_cur_pos(b)).bind(e)
				)
			e.get_node("btn").disabled=!e.runned and !e.neighbors.any(Callable(func(x):if is_instance_valid(x):return x.runned))
	set_cur_pos(current_pos)
	_post_ready()


	var t2=Time.get_time_dict_from_system()
	print(t2.minute*60+t2.second-t1.minute*60-t1.second)
	print("map_created")
	gm.set_dark(false)
	await gm.darked
	get_tree().set_deferred("paused",true)
func _pre_process(delta):pass
func _post_process(delta):pass
func _process(delta):
	_pre_process(delta)
	#if current_pos!=null:
	_post_process(delta)
func dijkstra(s: int, t: int, use_neighbors:bool=true):
	var inf =99999999999999999
	var visited: Array=[]
	for e in range(get_child_count()):
		visited.append(false)
	var distance: Array = []
	for e in range(get_child_count()):
		distance.append(inf)
	var prev: Array=[]
	for e in range(get_child_count()):
		prev.append(-1)
	distance[s] = 0

	while true:
		var min_distance: int = inf
		var min_vertex: int = -1
		for i in range(get_child_count()):
			if not visited[i] and distance[i] < min_distance:
				min_distance = distance[i]
				min_vertex = i

		if min_vertex == -1:
			break

		visited[min_vertex] = true
		var vertices=get_children()
		for neighbor in vertices[min_vertex].neighbors:
			if is_instance_valid(neighbor):
				var neighbor_id=neighbor.get_index()
				if not visited[neighbor_id] and distance[neighbor_id] > distance[min_vertex] + 1 and (neighbor.runned or !use_neighbors):
					distance[neighbor_id] = distance[min_vertex] + 1
					prev[neighbor_id] = min_vertex
	if distance[t] == inf:
		return []
	else:
		var path: Array = []
		var current: int = t
		while current != -1:
			path.push_front(current)
			current = prev[current]
		return path
func region_detection()->Array:
	var regions=[]
	var joined=[]
	var unjoined:=get_children()
	var i=0
	var none_count:=0
	var selected_id:=0
	var poss=Vector2.ZERO
	while !unjoined.is_empty() or !joined.is_empty():
		var e=null
		if !unjoined.is_empty():
			e=unjoined[i]
		if !unjoined.is_empty() and !dijkstra(e.get_index(),selected_id,false).is_empty():
			joined.append(e)
			poss+=e.global_position
			unjoined.remove_at(i)
			none_count=0
			i-=1
		else:
			none_count+=1
		if joined.size()==none_count:
			regions.append({"objs":joined.duplicate(true),"centr":poss/joined.size(),"count":joined.size()})
			poss=Vector2.ZERO
			joined.clear()
			if !unjoined.is_empty():
				selected_id=unjoined[fnc.rnd.randi_range(0,unjoined.size())].get_index()
			i=0
			none_count=0
		if unjoined.size()>0:
			i=(i+1)%unjoined.size()
	return regions
func is_on_corner(data:Array[Place],to:Place):
	if dijkstra(current_pos.get_index(),to.get_index(),false).is_empty():
		var port=data.duplicate()
		var nearsts=[]
		#for e in port.duplicate(true):
		port.sort_custom(
			(Callable(func(a, b):
				var dist_a = a.global_position.distance_to(to.global_position)
				var dist_b = b.global_position.distance_to(to.global_position)
				return dist_a < dist_b and a!=current_pos and b!=current_pos)
		))
		#print(port)
		#port=port.filter((func(x):
			#return (dijkstra(port[0].get_index(),port[1].get_index(),false).is_empty() and dijkstra(port[1].get_index(),port[0].get_index(),false).is_empty())
		#))
		#print(current_pos," ",to," ",port[0]," ",port[1])
		var res=(current_pos==port[0] or to==port[0]) and (current_pos==port[1] or to==port[1])
		#print(current_pos==port[0]," ", current_pos==port[1]," ",to==port[1]," ", to==port[0])
		#print(res)
		return res
	return false

func set_ingame_stats(place:Place):
	if place.ingame_statuses.is_empty() and !place.shop and place.arena!=null and place.arena.get_bosses().is_empty():
		var a:Array[ingame_status]=[]
		var keys:Array=gm.player_data.stats.keys()
		for e in range(fnc._with_chance_ulti([0.05,0.3,0.35,0.2,0.1])):
			var i_s=ingame_status.new()
			i_s.status=keys.pick_random()
			var stat_data:Dictionary=gm.objs.stats[i_s.status]
			if stat_data.has("v") and stat_data.has("-v"):
				var v_keys:Array=stat_data["v"].keys()
				var mv_keys:Array=stat_data["-v"].keys()
				var min=0
				var max=0
				if fnc._with_chance(0.5):
					min=stat_data["v"][mv_keys[0]].v.x
					max=stat_data["v"][v_keys[v_keys.size()-1]].v.y
				else:
					min=stat_data["-v"][mv_keys[0]].v.x
					max=stat_data["-v"][v_keys[v_keys.size()-1]].v.y
				i_s.value=snapped(fnc.rnd.randf_range(min,max),gm.objs.stats[i_s.status].step)
			else:
				i_s.value=fnc.rnd.randi_range(1,5)
			a.append(i_s)
			keys.remove_at(keys.find(i_s.status))
		if a.is_empty():
			a.append(ingame_status.new())
		place.ingame_statuses=a
