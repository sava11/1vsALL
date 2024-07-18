extends Control
#signal _load_data(node:Object,path:String)
#signal save_data_changed(dict:Dictionary)
#
#func save_data():
	#return {
		#str(get_path()):data_to_save()
	#}
#func data_to_save():
	#pass
#func load_data(n:Dictionary):
	#pass
@export var current_pos:place
@export var level_container:Node2D
func set_cur_pos(pos:place):
	if pos!=null:
		current_pos=pos
	else:
		current_pos=get_children()[fnc.rnd.randi_range(0,get_child_count()-1)]
	current_pos.runned=true
func _pre_ready():pass
func _post_ready():pass
func _ready():
	_pre_ready()
	#connect("save_data_changed",Callable(gm,"_save_node"))
	#connect("_load_data",Callable(gm,"_load_node"))
	#if !gm.sn.has(str(get_path())):
		#emit_signal("save_data_changed",save_data())
	#else:
		#emit_signal("_load_data",self,str(get_path()))
	set_cur_pos(current_pos)
	for e in get_children():
		if is_instance_valid(e):
			#e.runned_changed.connect(Callable(func(res):if res:current_pos=e))
			e.get_node("btn").button_down.connect(
				Callable(
					func(b:place):
						if b.runned and !dijkstra(current_pos.get_index(),b.get_index()).is_empty():
							current_pos=b
							gm.save_file_data()).bind(e)
				)
			e.get_node("btn").disabled=!e.runned and !e.neighbors.any(Callable(func(x):if is_instance_valid(x):return x.runned))
	_post_ready()
func _pre_process(delta):pass
func _post_process(delta):pass
func _process(delta):
	_pre_process(delta)
	if current_pos!=null:
		for cur_place in get_children():
			cur_place.player_here=cur_place==current_pos
			if cur_place.player_here and !cur_place.last_player_here:
				set_cur_pos(cur_place)
			cur_place.get_node("btn").disabled=!(cur_place.runned or current_pos.neighbors.find(cur_place)>-1)
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
