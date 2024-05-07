@tool
extends Control
@export var level_container:Node
@export var current_pos:place
@export var global_difficulty_add_step:float=0
@onready var shop=$shop/shop
@onready var map=$map/locs
var cur_loc:level_template
var item_rare:float=0
signal in_shop()
signal location_added(n:level_template)
signal place_completed()
func set_item_rare():
	var runned:int
	for e in $map/locs.get_children():
		runned+=int(e.runned)
	item_rare=float(runned)/float($map/locs.get_child_count())

signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)
func save_data():
	return {
		str(get_path()):{
			"cur_pos":str(current_pos.get_path()),
		}
	}
func load_data(n:Dictionary):
	current_pos=get_node(n["cur_pos"])
func _ready():
	if !Engine.is_editor_hint():
		connect("save_data_changed",Callable(gm,"_save_node"))
		connect("_load_data",Callable(gm,"_load_node"))
		add_to_group("SN")
		if !gm.sn.has(str(get_path())):
			emit_signal("save_data_changed",save_data())
		else:
			emit_signal("_load_data",self,str(get_path()))
		$stats/cont/back.hide()
		$shop.hide()
		$map.show()
		current_pos.get_node("btn").icon=load(gm.images.icons.charters.player)
		current_pos.runned=true
		for e in $map/locs.get_children():
			if is_instance_valid(e):
				e.get_node("btn").button_down.connect(
					Callable(
						func(b:place):
							if b.runned and !dijkstra(current_pos.get_index(),b.get_index()).is_empty():
								current_pos=b
								gm.save_file_data()).bind(e)
					)
				e.get_node("btn").disabled=!e.runned and !e.neighbors.any(Callable(func(x):return x.runned))
		
func _process(delta):
	if !Engine.is_editor_hint():
		for e in map.get_children():
			if e!=current_pos and e.get_node("btn").icon!=null and e.get_node("btn").icon.resource_path==gm.images.icons.charters.player :
				e.get_node("btn").icon=null
			if e==current_pos and (e.get_node("btn").icon==null or e.get_node("btn").icon.resource_path!=gm.images.icons.charters.player) and e.runned:
				e.get_node("btn").icon=load(gm.images.icons.charters.player)
		for cur_place in $map/locs.get_children():
			cur_place.get_node("btn").disabled=!(cur_place.runned or current_pos.neighbors.find(cur_place)>-1)


func level_completed(n:place):
	gm.game_prefs.dif+=n.local_difficulty_add_step+global_difficulty_add_step*int(n.local_difficulty_add_step==0)
	if gm.game_prefs.dif<0.5:
		gm.game_prefs.dif=0.5
	n.runned=true
	emit_signal("place_completed")

func dijkstra(s: int, t: int):
	var inf =99999999999999999
	var visited: Array=[]
	for e in range(map.get_child_count()):
		visited.append(false)
	var distance: Array = []
	for e in range(map.get_child_count()):
		distance.append(inf)
	var prev: Array=[]
	for e in range(map.get_child_count()):
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

var shop_items={}#object:[item1,...]

func cr_stats():
	var d0:Dictionary={}
	var d:Dictionary=gm.objs["stats"].duplicate()
	var d1:Dictionary=gm.player_data.stats.duplicate()
	
	for e in d1.keys():
		if fnc.i_search(d.keys(),e)!=-1:
			d0.merge({e:d[e]})
	return d0
func get_item_lvl(item_name,rare):
	var rares:PackedVector2Array=PackedVector2Array([])
	var lvls:PackedInt32Array=PackedInt32Array([])
	for e in gm.objs.updates[item_name].lvls.keys():
		rares.append(gm.objs.updates[item_name].lvls[e].rare)
		lvls.append(e)
	var c=fnc.find_betwen_lines(rare,rares)
	return lvls[c]
func _on_in_shop():
	for e in shop.get_children():
		e.queue_free()
	var all_items=gm.objs["updates"].duplicate()
	var items_names=all_items.keys()
	if shop_items[current_pos].has(""):
		shop_items[current_pos].erase("")
		for e in range(shop.columns):
			var n=all_items.keys()[fnc.rnd.randi_range(0,all_items.size()-1)]
			var item_lvl=get_item_lvl(n,item_rare)
			var sd=gm.objs.updates[n]
			var v=fnc._with_dific(sd["lvls"][item_lvl].value,fnc.rnd.randf_range(sd["lvls"][item_lvl].rare.x+gm.game_prefs.dif,sd["lvls"][item_lvl].rare.y+gm.game_prefs.dif))
			#updates.merge({n+"/"+str(e):})
			#добавить случайные значения
			var c_stats=sd["lvls"][item_lvl].stats.duplicate(true)
			for e1 in sd["lvls"][item_lvl].stats:
				if typeof(sd["lvls"][item_lvl].stats[e1])==TYPE_DICTIONARY:
					var l=max(len(str(sd["lvls"][item_lvl].stats[e1].x))-2,len(str(sd["lvls"][item_lvl].stats[e1].y))-2)
					var t=0.0
					if typeof(sd["lvls"][item_lvl].stats[e1].x)!=TYPE_INT or typeof(sd["lvls"][item_lvl].stats[e1].y)!=TYPE_INT:
						t=snapped(fnc.rnd.randf_range(sd["lvls"][item_lvl].stats[e1].x,sd["lvls"][item_lvl].stats[e1].y),pow(10,-l))
					else:
						t=fnc.rnd.randi_range(sd["lvls"][item_lvl].stats[e1].x,sd["lvls"][item_lvl].stats[e1].y)
					c_stats[e1]=t
			shop_items[current_pos].merge({n+"/"+str(e):{"lvl":item_lvl,"stats":c_stats,"val":fnc._with_dific(get_end_price(c_stats),gm.game_prefs.dif)}})
			
	$map.hide()
	$shop.show()
	$stats/cont/back.show()
	for e in shop_items[current_pos].keys():
		var item=preload("res://mats/UI/map/item.tscn").instantiate()
		item.item_name=e.split("/")[0]
		item.del_name=e
		item.lvl=shop_items[current_pos][e].lvl
		item.stats=shop_items[current_pos][e].stats
		item.value=shop_items[current_pos][e].val
		shop.add_child(item)
func _on_shop_exit_down():
	$map.show()
	$shop.hide()
	$stats/cont/back.hide()
	if shop_items[current_pos].is_empty():
		current_pos.runned=true
	for e in shop.get_children():
		e.queue_free()
func _upd_items_values():
	for shop in shop_items.keys():
		if !shop_items[shop].has("") and !shop_items[shop].is_empty():
			for n in shop_items[shop].keys():
				var item_lvl=shop_items[shop][n].lvl#get_item_lvl(, shop_items[shop])
				var sd=gm.objs.updates[n.split("/")[0]]["lvls"][item_lvl]
				
				var v=fnc._with_dific(sd.value,fnc.rnd.randf_range(sd.rare.x+gm.game_prefs.dif,sd.rare.y+gm.game_prefs.dif))
				shop_items[shop][n].val=v
func get_end_price(sts:Dictionary):
	var p=0.0
	for e in sts.keys():
		p+=sts[e]*gm.objs.stats[e].price
	return p
