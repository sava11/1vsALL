extends Game_map
signal game_ended
@export var col=25
@export var row=25

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

const distance_betveen_nodes=32
var max_neighbors=[0,0.3,0.6,0.05,0.05]
var neighbors:=[]
var exceptions:=[]
var bosses_pos:Array[Place]=[]
func _pre_ready():
	game_ended.connect(Callable(get_tree().current_scene,"game_ended"))
	fnc.rnd.seed=int(gm.game_prefs.seed)
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
		#exceptions.sort_custom((func(a, b):
			#var dist_a = a.distance_to(Vector2.ZERO)
			#var dist_b = b.distance_to(Vector2.ZERO)
			#return dist_a < dist_b))
	else:
		for e in get_children():
			e.free()
	gen_map_v1(exceptions,neighbors)
	emit_signal("map_generated")
func create_arena():
	var arena=arena_action.new()
	var enemys=(func():
		var enemys_path=["res://mats/enemys/e1/enemy.tscn","res://mats/enemys/e2/enemy.tscn",
		"res://mats/enemys/e3/enemy.tscn","res://mats/enemys/e4/enemy.tscn"]
		var select_enemys_percents=[0.5,0.35,0.1,0.05]
		var count_enemys_percents=[0.3,0.35,0.25,0.1]
		var ens:Array[empty_entety_data]=[]
		var count=fnc._with_chance_ulti([0.05,0.5,0.4,0.1])+1
		for i in range(count):
			var enemy=enemy_data.new()
			var e_p_id=fnc._with_chance_ulti(select_enemys_percents)
			enemy.enemy=enemys_path[e_p_id]
			enemy.percent=1.0/float(count)
			enemys_path.remove_at(e_p_id)
			select_enemys_percents.remove_at(e_p_id)
			ens.append(enemy)
		return ens).call()
	arena.enemys=enemys
	arena.enemys_count_min=fnc.rnd.randi_range(3,5)
	arena.enemys_count_max=fnc.rnd.randi_range(arena.enemys_count_min,8)
	return arena

func gen_map_v1(positions:Array,neighbors:Array):
	var lvls=["res://mats/lvls/lvl1/lvl1_1.tscn","res://mats/lvls/lvl1/lvl1_2.tscn"]
	var nearst_points:=get_regions_positions()
	for i in range(nearst_points.size()):
		var e:Vector2=nearst_points[i]
		positions.sort_custom((func(a,b):
			var dist_a = a.distance_to(e)
			var dist_b = b.distance_to(e)
			return dist_a < dist_b))
		nearst_points[i]=positions[0]
		
	var regions_color:=get_regions_colors()
	var regions_places:={}
	var setted:Array[Place]=[]
	for e in positions:
		var scn:Place=preload("res://mats/UI/map/place/place.tscn").instantiate()
		scn.position=e*int((fnc._sqrt(scn.size)+distance_betveen_nodes))#16+32
		#if e in nearst_points:
		scn.zone=fnc.i_search(nearst_points,e)
		if scn.zone!=-1:
			regions_places.merge({scn.zone:[scn]})
			scn.level=regions[scn.zone].get_level()
			scn.set_region(regions[scn.zone])
			setted.append(scn)
		#scn.choice_panel_showed.connect(Callable(self,"set_ingame_stats").bind(scn))
		var shop_chance=fnc._with_chance(0.1)
		if shop_chance:
			scn.shop=true
			if fnc._with_chance(0.25):
				scn.arena=create_arena()
				scn.local_difficulty_add_step=fnc.rnd.randf_range(0,0.2)
		else:
			scn.arena=create_arena()
			scn.local_difficulty_add_step=fnc.rnd.randf_range(0.05,0.2)
		add_child(scn)
	print("arenas created")
	await get_tree().process_frame
	
	var mass:=get_children()
	var d:={}
	var temp_mass=mass.duplicate(true)
	for e:Place in mass:
		temp_mass.sort_custom(Callable(func(a, b):
			var dist_a = a.global_position.distance_to(e.global_position)
			var dist_b = b.global_position.distance_to(e.global_position)
			return dist_a < dist_b and a!=e and b!=e))
		var local_angs=[]
		for k in range(neighbors[e.get_index()]):
			var ang=snapped(fnc.angle(temp_mass[k].global_position.direction_to(e.global_position)),0.01)
			#var dist:=int((fnc._sqrt(e.size)+distance_betveen_nodes))
			#var dist=temp_mass[k].global_position.distance_to(e.global_position)>=fnc._sqrt(Vector2(dist,dist))
			if fnc.i_search(local_angs,ang)==-1 and e.neighbors.find(temp_mass[k])==-1:
				local_angs.append(ang)
				e.neighbors.append(temp_mass[k])
				temp_mass[k].neighbors.append(e)
				if len(temp_mass[k].neighbors)>=2 and fnc._with_chance(0.075):
					temp_mass[k].secret=true
	print("neighbors applyed")
	await get_tree().process_frame
	
	while !setted.is_empty():
		var temped:=[]
		for e in setted[0].neighbors:
			if e.zone==-1:
				e.zone=setted[0].zone
				regions_places[e.zone].append(e)
				e.level=regions[e.zone].get_level()
				e.set_region(regions[e.zone])
				setted.append(e)
		setted.remove_at(0)
	print("regions applyed")
	await get_tree().process_frame
	
	var bosses:Array[String]=["res://mats/enemys/b2/enemy.tscn","res://mats/enemys/b3/enemy.tscn",
	"res://mats/enemys/b4/enemy.tscn","res://mats/enemys/b5/enemy.tscn"]
	#var place_with_bosses=[]
	var filtered_mass=mass.duplicate(true).filter((func(x):
		return !x.secret and !x.shop))
	#var start_node:Place=filtered_mass[fnc.rnd.randi_range(0,len(filtered_mass)-1)]
	for e in regions_places.keys():
		#var i:=0
		regions_places[e]=regions_places[e].filter((func(x):
			return !x.secret and !x.shop))
		#var cur_node:Place=arr[i]
		#var ended:=false
		#while !ended:
			#arr=arr.filter((func(x:Place):
				#return x==cur_node or cur_node.global_position.distance_to(x.global_position)>4*(x.size.x+distance_betveen_nodes)
			#))
			# regions_places[e]=arr
			#i=arr.find(cur_node)+1
			#cur_node=arr[i%arr.size()]
			#if cur_node==arr[0]:
				#ended=true
				#print("zone ",e," is complete")
	
	#print("testing regions")
	#await get_tree().process_frame
	#print(regions_places.keys())
	for e in range(bosses.size()):
		if bosses[0]!="":
			var bd=boss_data.new()
			bd.boss=bosses[0]
			bd.name=bosses[0]
			var cur_region:Array=regions_places[get_region_where_boss_scene_path_is(bd.boss)]
			var node:Place=cur_region[fnc.rnd.randi_range(0,cur_region.size()-1)]
			#while dijkstra(node.get_index(),0,false).is_empty() or node.arena.has_bosses():
				#node=filtered_mass[fnc.rnd.randi_range(0,len(filtered_mass)-1)]
			#place_with_bosses.append(node)
			bosses_pos.append(node)
			node.arena.enemys.append(bd)
			node.arena.spawning=false
			node.ingame_statuses.clear()
			node.img_think()
		bosses.remove_at(0)
	
	
	map_is_generated=true
	emit_signal("map_generated")
	print("bosses created")
	#await get_tree().process_frame
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

#func set_ingame_stats(_place:place):
	#if _place.ingame_statuses.is_empty():
		#var a:Array[ingame_status]=[]
		#var keys:Array=gm.player_data.stats.keys()
		#var unlocked_data=[]
		#for e in range(fnc._with_chance_ulti([0.05,0.4,0.35,0.2])):
			##var i_s=ingame_status.new()
			##i_s.status=keys.pick_random()
			#var stat_data:Dictionary=gm.objs.stats[i_s.status]
			##"v":{
			##	0:{"v":{"x":1,"y":2},"%":0,},
			#print(stat_data)
			#if stat_data.has("v") and stat_data.has("-v"):
				#var choiced:=[]
				#var t="-v"
				#if fnc._with_chance(0.5):
					#t="v"
				#for x in stat_data[t].keys():
					#print(x," ",stat_data[t][x])
					#if stat_data[t][x]["%"]<=get_rare():
						#choiced.append(x)
				#print(choiced)
				#var rnd_lvl=choiced.pick_random()
				##var v_keys:Array=stat_data["v"].keys()
				##var mv_keys:Array=stat_data["-v"].keys()
				#var min=stat_data[t][rnd_lvl].v.x
				#var max=stat_data[t][rnd_lvl].v.y
				#i_s.value=snapped(fnc.rnd.randf_range(min,max),0.001)
			#else:
				#i_s.value=fnc.rnd.randi_range(1,5)
			#a.append(i_s)
		#_place.ingame_statuses=a
func _pre_process(delta):
	if Input.is_action_just_pressed("ui_left"):print(_get_dif()," ",_get_process_ratio())
	queue_redraw()

#var clrs=[Color("RED"),Color("Silver"),Color("ORANGE"),Color("WHITE")]
#var trs=["res://mats/enemys/b2/enemy.tscn","res://mats/enemys/b3/enemy.tscn",
#"res://mats/enemys/b4/enemy.tscn","res://mats/enemys/b5/enemy.tscn"]
func _draw():
	if current_pos!=null and map_is_generated:
		var i:=0
		for p in bosses_pos:
			#var clr:=Color(1,1,1,1)
			#for e in range(trs.size()):
				#if p.arena.get_boss_by_name(trs[e]):
					#clr=clrs[e]
			if !p.runned:
				draw_line(current_pos.position+current_pos.size/2,p.position+p.size/2,Color("ff506e"),5)
			else:
				i+=1
		if i==bosses_pos.size():
			set_process(false)
			emit_signal("game_ended")
