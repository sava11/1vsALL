@tool
extends Control
@export var level_container:Node
@export var current_pos:place
@export var global_difficulty_add_step:float=0
@onready var shop=$shop/shop
@onready var map=$map/cont/locs/map
@onready var stat_cont=$stats/cont/ScrollContainer/item_cont
@export_category("zone_colors")
var cur_loc:level_template
var item_rare:float=0
signal in_shop()
signal location_added(n:level_template)
signal place_completed()
func set_item_rare():
	var runned:int
	for e in $map/cont/locs/map.get_children():
		runned+=int(e.runned)
	item_rare=float(runned)/float($map/cont/locs/map.get_child_count())

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
		#rand_lvl_gen(50)
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
		current_pos.runned=true
		for e in $map/cont/locs/map.get_children():
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
		var stats_keys=gm.player_data.stats.keys()
		for e in DirAccess.get_files_at("res://mats/statuses"):
			var res:status=load("res://mats/statuses/"+e)
			var item=preload("res://mats/UI/new_map/item/item.tscn").instantiate()
			item.item_name=res.name
			stat_cont.add_child(item)
			item.set_image(res.image)
			item.set_item_name(tr(res.translation_name))
			item.set_value(snapped(gm.player_data.stats[res.name],0.001),res.suffix)
		for i in stat_cont.get_children():
			var id=stats_keys.find(i.item_name)
			if id!=i.get_index():
				stat_cont.move_child(i,id)

func get_max_map_lenght():
	var mx=-Vector2(999999999,999999999)
	for e in map.get_children():
		if e.visible:
			if e.position.x+e.size.x>mx.x:
				mx.x=e.position.x+e.size.x
			if e.position.y>mx.y:
				mx.y=e.position.y+(e.size.y-20)
	return mx
func _process(delta):
	if has_node("map/cont/locs/map"):
		var mx=get_max_map_lenght()
		$map/cont/locs.set("theme_override_constants/margin_left",mx.x/2)
		$map/cont/locs.set("theme_override_constants/margin_right",mx.x/2)
		$map/cont/locs.set("theme_override_constants/margin_top",mx.y/2)
		$map/cont/locs.set("theme_override_constants/margin_bottom",mx.y/2)
		get_node("map/cont/locs/map").custom_minimum_size=get_max_map_lenght()
	if has_node("map/cont/locs/map") and !Engine.is_editor_hint():
		for e in $map/cont/locs/map.get_children():
			e.player_here=e==current_pos
			if e.player_here and !e.last_player_here:
				var w=e.position.x+$map/cont/locs.get("theme_override_constants/margin_left")/2.5
				$map/cont.scroll_horizontal=w
				var h=e.position.y-$map/cont/locs.get("theme_override_constants/margin_top")/2.5
				$map/cont.scroll_vertical=h
				
				#$map/cont/locs.position=$map/cont.position+$map/cont.size/2-e.position-e.size/2
				#slow
				#$map/cont/locs/map.position=$map/cont/locs.position.move_toward($map/cont.position+$map/cont.size/2-e.position-e.size/2,130*delta)
		if current_pos!=null:
			for cur_place in $map/cont/locs/map.get_children():
				cur_place.get_node("btn").disabled=!(cur_place.runned or current_pos.neighbors.find(cur_place)>-1)
		

func level_completed(n:place):
	gm.game_prefs.dif+=n.local_difficulty_add_step+global_difficulty_add_step*int(n.local_difficulty_add_step==0)
	if gm.game_prefs.dif<0.5:
		gm.game_prefs.dif=0.5
	n.runned=true
	for e in n.ingame_statuses:
		fnc.get_hero().add_stats.merge({e.editable_status.name:e.value})
		for i in stat_cont.get_children():
			if i.get_node("item_name").text==tr(e.editable_status.translation_name):
				i.set_value(i.value+e.value,e.editable_status.suffix)
	fnc.get_hero().merge_stats()
	gm.player_data.in_action=""
	current_pos=n
	gm.save_file_data()
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
		for i in range(map.get_child_count()):
			if not visited[i] and distance[i] < min_distance:
				min_distance = distance[i]
				min_vertex = i

		if min_vertex == -1:
			break

		visited[min_vertex] = true
		var vertices=map.get_children()
		for neighbor in vertices[min_vertex].neighbors:
			if is_instance_valid(neighbor):
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

#func maket_dijkstra(s: int, t: int,data):
	#var inf =99999999999999999
	#var visited: Array=[]
	#for e in range(len(data)):
		#visited.append(false)
	#var distance: Array = []
	#for e in range(len(data)):
		#distance.append(inf)
	#var prev: Array=[]
	#for e in range(len(data)):
		#prev.append(-1)
	#distance[s] = 0
#
	#while true:
		#var min_distance: int = inf
		#var min_vertex: int = -1
		#for i in range(len(data)):
			#if not visited[i] and distance[i] < min_distance:
				#min_distance = distance[i]
				#min_vertex = i
#
		#if min_vertex == -1:
			#break
#
		#visited[min_vertex] = true
		#var vertices=data
		#for neighbor in vertices[min_vertex]:
			#if not visited[neighbor] and distance[neighbor] > distance[min_vertex] + 1:
				#distance[neighbor] = distance[min_vertex] + 1
				#prev[neighbor] = min_vertex
#
	#if distance[t] == inf:
		#return []
	#else:
		#var path: Array = []
		#var current: int = t
		#while current != -1:
			#path.push_front(current)
			#current = prev[current]
		#return path

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
