extends Panel
@export_range(2,99) var choices_colums:int=3
@export_range(1,999) var colums:int=1
@export_range(1,999) var rows:int=1
var start_position:Vector2=Vector2(-1,-1)
@export var max_size:Vector2=Vector2(200,150)
@onready var cont=$gc
@export var boss_spawn_ids:PackedInt32Array=[14,19,9]
@export_range(0,999) var shop_count:int=3
@export_range(0,999) var start_posid:int=10
signal in_shop
var posid=0
var bst={}
var b_boss={}
var shop_items={}#shop_id:[iem_id, ...]
var item_rare:float=0
var max_column=0

@onready var map_execptions=PackedInt32Array([start_posid])
@onready var shop=$shop_cont/shop
var bossid=0
func get_id_in_cont(bid:int,offset:Vector2=Vector2.ZERO,clamps:Vector2=Vector2(1,1)):
	var x=bid%int(clamps.x)
	var y=clamp(int(clamps.y+offset.y),1,9999999)
	var y1=(bid-x+clamps.x*offset.y)/y
	var e=int(x+y1*clamps.y)
	return int(e)
func get_item_lvl(item_name,rare):
	var rares:PackedVector2Array=PackedVector2Array([])
	var lvls:PackedInt32Array=PackedInt32Array([])
	for e in gm.objs.items[item_name].lvls.keys():
		rares.append(gm.objs.items[item_name].lvls[e].rare)
		lvls.append(e)
	var c=fnc.find_betwen_lines(rare,rares)
	return lvls[c]

func cr_shops():
	for e in shop.get_children():
		e.queue_free()
	for tt in range(shop_count):
		var id=gm.rnd.randi_range(0,colums*rows-1)
		while bossid==id or shop_items.has(id)==true or id==start_posid:
			id=gm.rnd.randi_range(0,colums*rows-1)
			#items_names.remove_at(fnc.i_search(items_names,n))
		shop_items.merge({id:{"":0}})
func cr_stats():
	var d0:Dictionary={}
	var d:Dictionary=gm.objs["stats"].duplicate()
	var d1:Dictionary=fnc.get_hero().cd.stats.duplicate()
	
	for e in d1.keys():
		if fnc.i_search(d.keys(),e)!=-1:
			d0.merge({e:d[e]})
	return d0
func _ready():
	posid=start_posid
	bossid=boss_spawn_ids[gm.rnd.randi_range(0,len(boss_spawn_ids)-1)]
	var cd=cr_stats()
	var tt:Array=cd.keys()
	for e in range(len(tt)):
		var e1=preload("res://mats/UI/map/elems.tscn").instantiate()
		e1.img=load(cd[tt[e]].i)
		e1.txt=str(fnc.get_hero().cd.stats[tt[e]])
		$Panel/gc.add_child(e1)
		e1.popup_text=cd[tt[e]].t
		e1.show_popup_text=true
	var point=posid
	cr_shops()
	var w=int(cont.size.x/colums)
	var h=cont.size.y/rows
	cont.columns=colums
	var bid=0
	for e in cont.get_children():
		e.queue_free()
	for e in range(colums*rows):
		var b1=preload("res://mats/UI/map/button.tscn").instantiate()
		b1.cd=cd
		if max_size.x<w:
			b1.custom_minimum_size.x=max_size.x
		else:
			b1.custom_minimum_size.x=w-2
		if max_size.y<h:
			b1.custom_minimum_size.y=max_size.y
		else:
			b1.custom_minimum_size.y=h-2
		var rmax=clamp(gm.rnd.randi_range(0,5),0,99)
		if rmax>0:
			b1.min_range=1
			b1.max_range=rmax
		b1.ivents_imgs.clear()
		if fnc.i_search(shop_items.keys(),e)!=-1:
			b1.ivents_imgs.append("res://mats/imgs/icons/maney.png")
			b1.shop=true
		if e == bossid:
			var list=gm.bosses[clamp(get_tree().current_scene.lvl,0,len(gm.bosses.keys())-1)]
			var boss_d=list[gm.rnd.randi_range(0,len(list)-1)]
			b1.boss=PackedStringArray([boss_d.b])
			b1.ivents_imgs.append(boss_d.i)
		cont.add_child(b1)
	upd(point)
func upd(point:int):
	var pointy=(point-point%rows)/rows
	var w=int(cont.size.x/colums)
	var h=cont.size.y/rows
	cont.columns=colums
	if max_column<posid%colums:
		max_column=posid%colums
	var bid=0
	for e in range(colums*rows):
		var b1=cont.get_child(e)
		b1.disabled=true
		if b1.get_index()==point:
			b1.text="(You)"
			bid=b1.get_index()
		elif fnc.i_search(map_execptions,e)!=-1:
			b1.text="X"
		else:
			b1.text=""
	for e in range(clamp(bid%rows-1,0,rows)+clamp(pointy-1,0,colums-1)*rows, 
	clamp(bid%rows+2,0,rows)+clamp(pointy-1,0,colums-1)*rows):
		if e != bid:cont.get_child(e).disabled=false
	for e in range(clamp(bid%rows-1,0,rows)+clamp(pointy,0,colums-1)*rows, 
	clamp(bid%rows+2,0,rows)+clamp(pointy,0,colums-1)*rows):
		if e != bid or cont.get_child(e).shop==true:cont.get_child(e).disabled=false
	for e in range(clamp(bid%rows-1,0,rows)+clamp(pointy+1,0,colums-1)*rows, 
	clamp(bid%rows+2,0,rows)+clamp(pointy+1,0,colums-1)*rows):
		if e != bid:cont.get_child(e).disabled=false
	item_rare=float(get_tree().current_scene.lvl*colums+(max_column))/float((gm.maps.keys().max()+1)*colums)
func upd_stats():
	var cd=cr_stats()
	var tt:Array=cd.keys()
	for e in range($Panel/gc.get_child_count()):
		var e1=$Panel/gc.get_child(e)
		e1.txt=str(fnc.get_hero().cd.stats[tt[e]])

func _physics_process(delta):
	$hero_values/cont/money.txt=str(fnc.get_hero().money)
	$hero_values/cont/xp/pg.value=fnc.get_hero().exp
	$hero_values/cont/xp/pg.max_value=fnc.get_hero().cd.prefs["max_exp_start"]
	$hero_values/cont/xp/pg/txt.text="\tlvl - "+str(fnc.get_hero().lvl)
	if visible==true:
		if get_tree().paused==false:
			get_tree().set_deferred("paused",true)
	else:
		if get_tree().paused==true:
			get_tree().set_deferred("paused",false)
func upd_b_stats():
	var cd=cr_stats()
	shop_items.clear()
	posid=start_posid
	bossid=boss_spawn_ids[gm.rnd.randi_range(0,len(boss_spawn_ids)-1)]
	bst.clear()
	map_execptions=PackedInt32Array([posid])
	max_column=posid%colums
	cr_shops()
	for e in $areas.get_children():
		e.queue_free()
	for e in range(colums*rows):
		var b1=cont.get_child(e)
		b1.shop=0
		b1.icon=null
		b1.cd=cd
		b1.ivents_imgs.clear()
		if fnc.i_search(shop_items.keys(),e)!=-1:
			b1.ivents_imgs.append("res://mats/imgs/icons/maney.png")
			b1.shop=1
		b1.boss.clear()
		var rmax=clamp(gm.rnd.randi_range(0,4),0,99)*int(!bool(b1.shop) and b1.shop!=2) 
		if rmax>0:
			b1.min_range=1
			b1.max_range=rmax
		else:
			b1.min_range=0
			b1.max_range=0
		if e == bossid:
			var list=gm.bosses[clamp(get_tree().current_scene.lvl,0,len(gm.bosses.keys())-1)]
			var boss_d=list[gm.rnd.randi_range(0,len(list)-1)]
			b1.boss=PackedStringArray([boss_d.b])
			b1.ivents_imgs.append(boss_d.i)
		var area=Polygon2D.new()
		area.polygon=PackedVector2Array([
			Vector2(-2,-2),
			Vector2(b1.custom_minimum_size.x+2,-2),
			Vector2(b1.custom_minimum_size.x+2,b1.custom_minimum_size.y+2),
			Vector2(-2,b1.custom_minimum_size.y+2),
			
			
			])
		area.position=(b1.custom_minimum_size+Vector2(4,4))*Vector2(b1.get_index()%colums,(b1.get_index()-b1.get_index()%colums)/rows)-Vector2(2,2)#b1.position-Vector2(2,2)#-b1.custom_minimum_size/2
		area.color=Color()
		$areas.add_child(area)
		b1.upd_stats()
	
	upd(posid)
	upd_stats()

func _on_in_shop():
	for e in shop.get_children():
		e.queue_free()
	var all_items=gm.objs["items"].duplicate()
	var items_names=all_items.keys()
	if shop_items[posid].has(""):
		shop_items[posid].erase("")
		for e in range(4):
			var n=all_items.keys()[gm.rnd.randi_range(0,all_items.size()-1)]
			var item_lvl=get_item_lvl(n,item_rare)
			var sd=gm.objs.items[n]
			var v=fnc._with_dific(sd["lvls"][item_lvl].value,gm.rnd.randf_range(sd["lvls"][item_lvl].rare.x+get_tree().current_scene.dif,sd["lvls"][item_lvl].rare.y+get_tree().current_scene.dif))
			#items.merge({n+"/"+str(e):})
			shop_items[posid].merge({n+"/"+str(e):{"lvl":item_lvl,"val":v}})
			
	$gc.hide()
	$shop_cont.show()
	for e in shop_items[posid].keys():
		var item=preload("res://mats/UI/map/item.tscn").instantiate()
		item.item_name=e.split("/")[0]
		item.del_name=e
		item.lvl=shop_items[posid][e].lvl
		item.value=shop_items[posid][e].val
		shop.add_child(item)
func _on_shop_exit_down():
	$gc.show()
	$shop_cont.hide()
	if shop_items[posid].is_empty():
		map_execptions.append(posid)
	for e in shop.get_children():
		e.queue_free()
func _upd_items_values():
	for shop in shop_items.keys():
		if !shop_items[shop].has("") and !shop_items[shop].is_empty():
			for n in shop_items[shop].keys():
				var item_lvl=shop_items[shop][n].lvl#get_item_lvl(, shop_items[shop])
				var sd=gm.objs.items[n.split("/")[0]]["lvls"][item_lvl]
				var v=fnc._with_dific(sd.value,gm.rnd.randf_range(sd.rare.x+get_tree().current_scene.dif,sd.rare.y+get_tree().current_scene.dif))
				shop_items[shop][n].val=v
