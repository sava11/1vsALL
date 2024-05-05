@tool
extends Control
@export var level_container:Node
@export var current_pos:place
@export var global_difficulty_add_step:float=0
var cur_loc:level_template
func save_data():
	return {
		"cur_pos":str(current_pos.get_path())
	}
func load_data(n:Dictionary):
	current_pos=get_node(n["cur_pos"])
#var connect_table=[]
func _ready():
	if !Engine.is_editor_hint():
		#for e in $map/locs.get_children():
			#var t=[]
			#t.append_array(e.neighbors)
			#connect_table.append(t)
		current_pos.get_node("btn").icon=load(gm.images.icons.charters.player)
		current_pos.runned=true
		for e in $map/locs.get_children():
			if is_instance_valid(e):
				
				e.runned_changed.connect(Callable(func(b:bool):if b:current_pos=e))
				e.get_node("btn").button_down.connect(
					Callable(
						func(b:place):
							if b.runned and !dijkstra(current_pos.get_index(),b.get_index()).is_empty():
								current_pos=b).bind(e)
					)
				e.get_node("btn").disabled=!e.runned and !e.neighbors.any(Callable(func(x):return x.runned))
func _process(delta):
	if !Engine.is_editor_hint():
		for e in $map/locs.get_children():
			if e!=current_pos and e.get_node("btn").icon!=null and e.get_node("btn").icon.resource_path==gm.images.icons.charters.player :
				e.get_node("btn").icon=null
			if e==current_pos and (e.get_node("btn").icon==null or e.get_node("btn").icon.resource_path!=gm.images.icons.charters.player) and e.runned:
				e.get_node("btn").icon=load(gm.images.icons.charters.player)
	for cur_place in $map/locs.get_children():
		cur_place.get_node("btn").disabled=!(cur_place.runned or current_pos.neighbors.find(cur_place)>-1)
func dijkstra(s: int, t: int):
	var inf =99999999999999999
	var visited: Array=[]
	for e in range($map/locs.get_child_count()):
		visited.append(false)
	var distance: Array = []
	for e in range($map/locs.get_child_count()):
		distance.append(inf)
	var prev: Array=[]
	for e in range($map/locs.get_child_count()):
		prev.append(-1)
	distance[s] = 0

	while true:
		var min_distance: int = inf
		var min_vertex: int = -1
		for i in range($map/locs.get_child_count()):
			if not visited[i] and distance[i] < min_distance:
				min_distance = distance[i]
				min_vertex = i

		if min_vertex == -1:
			break

		visited[min_vertex] = true
		var vertices=$map/locs.get_children()
		for neighbor in vertices[min_vertex].neighbors:
			var neighbor_id=neighbor.get_index()
			if not visited[neighbor_id] and distance[neighbor_id] > distance[min_vertex] + 1 and neighbor.runned:
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
