extends Control

var current_pos:place
@export var global_difficulty_add_step:float=0
@onready var shop=$shop/shop
@onready var map
@onready var stat_cont=$stats/cont/ScrollContainer/item_cont

var cur_loc:level_template
var item_rare:float=0
signal in_shop()
signal location_added(n:level_template)
signal place_completed()
func set_item_rare():
	var runned:int
	for e in map.get_children():
		runned+=int(e.runned)
	item_rare=float(runned)/float(map.get_child_count())

#func show_death(b:bool=true):
	#for e in map.get_children():
		#if b:
			#e.visible=e.name.contains("death")
		#else:
			#e.visible=!e.name.contains("death")
func _ready():
	if !Engine.is_editor_hint():
		#rand_lvl_gen(50)
		$stats/cont/back.hide()
		$shop.hide()
		$map.show()
		var stats_keys=gm.player_data.stats.keys()
		for e in gm.player_data.stats:
			var item=preload("res://mats/UI/map/status_item/item.tscn").instantiate()
			item.item_name=e
			stat_cont.add_child(item)
			item.set_image(load(gm.objs.stats[e].i))
			item.set_item_name(tr(gm.objs.stats[e].ct))
			item.set_tooltip(tr(gm.objs.stats[e].t))
			item.set_value(snapped(gm.player_data.stats[e],0.001),gm.objs.stats[e].postfix)
		for i in stat_cont.get_children():
			var id=stats_keys.find(i.item_name)
			if id!=i.get_index():
				stat_cont.move_child(i,id)

func get_max_map_lenght():
	var mn:=Vector2(999999999,999999999)
	var mx=-Vector2(999999999,999999999)
	if map!=null:
		for e in map.get_children():
			if e.visible:
				if e.position.x+e.size.x<mn.x:
					mn.x=e.position.x+e.size.x
				if e.position.y<mn.y:
					mn.y=e.position.y+(e.size.y)#-20)
		for e in map.get_children():
			if e.visible:
				if e.position.x+e.size.x>mx.x:
					mx.x=e.position.x+e.size.x
				if e.position.y>mx.y:
					mx.y=e.position.y+(e.size.y)#-20)
		return mx-mn
	else:
		return 0
var temp_drag:=Vector2.ZERO
func _process(delta):
	#if Engine.is_editor_hint():
		#for e in map.get_children():
			#e.modulate=Color.WHITE
			#if e is place and e.ingame_statuses!=null:
				#for i in e.ingame_statuses:
					#if i.status=="":
						#e.modulate=Color.YELLOW_GREEN
	if $map/cont/locs.get_child_count()==1 and !Engine.is_editor_hint():
		map=get_node("map/cont/locs").get_child(0)
		map.custom_minimum_size=get_max_map_lenght()
		var s=fnc.get_prkt_win()
		var a=get_local_mouse_position() - s * 0.5
		var cur_drag:Vector2=Vector2($map/cont.scroll_horizontal,$map/cont.scroll_vertical)
		if Input.is_action_just_pressed("rmb"):
			temp_drag=cur_drag+a
		if Input.is_action_pressed("rmb"):
			cur_drag=-a+temp_drag
			$map/cont.scroll_horizontal=cur_drag.x
			$map/cont.scroll_vertical=cur_drag.y
		#if current_pos!=null:
			#for cur_place in map.get_children():
				#cur_place.get_node("btn").disabled=!(cur_place.runned or current_pos.neighbors.find(cur_place)>-1)
				
func upd_by_sts():
	for e in gm.player_data.stats:
		for i in stat_cont.get_children():
			if i.get_node("item_name").text==tr(gm.objs.stats[e].ct):
				i.set_value(gm.player_data.stats[e],gm.objs.stats[e].postfix)

func level_completed(n:place):
	gm.game_prefs.dif+=n.local_difficulty_add_step+global_difficulty_add_step*int(n.local_difficulty_add_step==0)
	#if gm.game_prefs.dif<0.5:
		#gm.game_prefs.dif=0.5
	n.runned=true
	var temp_d={}
	for e in n.ingame_statuses:
		temp_d.merge({e.status:e.value})
	gm.merge_stats(temp_d)
	upd_by_sts()
	gm.player_data.in_action=""
	set_cur_pos(n)
	emit_signal("place_completed")
	gm.save_file_data()
func set_cur_pos(p:place):
	current_pos=p
	var w=p.position.x
	$map/cont.scroll_horizontal=w+p.size.x/2-$map/cont/locs.get("theme_override_constants/margin_left")
	var h=p.position.y
	$map/cont.scroll_vertical=h+p.size.y/2-$map/cont/locs.get("theme_override_constants/margin_bottom")
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
		var item=preload("res://mats/UI/map/shop_item/item.tscn").instantiate()
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
func _on_player_no_he():
	get_parent().get_node("game_ui/death").show()
	get_tree().set_deferred("paused",true)
