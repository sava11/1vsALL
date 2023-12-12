extends Button
@export_range(0,999) var min_range:int=0
@export_range(0,999) var max_range:int=0
@onready var map=get_parent().get_parent().get_parent()
var sd={}
var cd={}
var ivents_imgs:PackedStringArray=[]
var boss:PackedStringArray
var enemys:PackedStringArray
var shop:int=0
var exit:bool=false
func show_icons():
	$tcont/img_layer_cont.imgs_paths=ivents_imgs
	$tcont/img_layer_cont._upd_()
func clear():
	sd.clear()
	for e in $tcont/vb.get_children():
		e.queue_free()
	ivents_imgs=PackedStringArray([])
	show_icons()
	shop=0
	exit=false
	enemys.clear()
	boss.clear()
func set_color(state:String,color1:Color,color2:Color):
	get("theme").get("Button/styles/"+state).set("bg_color",color1)
	get("theme").get("Button/styles/"+state).set("border_color",color2)
func upd_stats():
	var l=gm.maps[get_tree().current_scene.get("lvl")].get("lvl_color",
		{"normal":{"bg":Color("252525"),"brd":Color("959595")},
		"pressed":{"bg":Color("515151"),"brd":Color("959595")},
		"hover":{"bg":Color("323232"),"brd":Color("959595")},
		"disabled":{"bg":Color("474747"),"brd":Color("959595")},},)
	for e in l.keys():
		set_color(e,l[e].bg,l[e].brd)
	#$tcont/vs.value=0
	for e in $tcont/vb.get_children():
		e.queue_free()
	$tcont/img_layer_cont.imgs_paths=ivents_imgs
	$tcont/img_layer_cont._upd_()
	if !ivents_imgs.is_empty():alignment=HORIZONTAL_ALIGNMENT_LEFT
	else:alignment=HORIZONTAL_ALIGNMENT_CENTER
	var tt:Array=cd.keys().duplicate()
	if map.bst.get(get_index())==null:
		var val=fnc.rnd.randi_range(min_range,max_range)
		while sd.size()<val:
			var n=tt[fnc.rnd.randi_range(0,len(tt)-1)]
			var d =cd[n].get(fnc._with_chance_custom_values(0.65,"v","-v"),"v")
			var perc=[]
			for e in d.keys():perc.append(d[e]["%"])
			var v=0
			var stat=d[fnc._with_chance_ulti(perc)]["v"]
			var temp=abs(max(len(str(abs(stat.x)))-2,len(str(abs(stat.y)))-2))
			if typeof(stat.x)==TYPE_INT and typeof(stat.y)==TYPE_INT:
				v=snapped(fnc.rnd.randi_range(stat.x,stat.y),pow(10,-temp))
			else:
				v=snapped(fnc.rnd.randf_range(stat.x,stat.y),pow(10,-temp))
			if cd[n].min_v<=fnc.get_hero().cd.stats[n]+v:
			#	d=cd[n].get("v")
			#	v=0
			#	if d.x!=float(int(d.x)):
			#		v=snapped(gm.rnd.randf_range(d.x,d.y),0.01)
			#	elif d.x==float(int(d.x)):
			#		v=fnc.rnd.randi_range(d.x,d.y)
				sd.merge({n:v},true)
				tt.erase(n)
				var e1=preload("res://mats/UI/map/elems.tscn").instantiate()
				e1.img=load(cd[n].i)
				if v>0:
					e1.txt="+"+str(v)
				else:
					e1.txt=str(v)
				$tcont/vb.add_child(e1)
				e1.mouse_filter=Control.MOUSE_FILTER_IGNORE
		map.bst.merge({get_index():sd})
	else:
		sd=map.bst.get(get_index())
		for e in sd.keys():
			var e1=preload("res://mats/UI/map/elems.tscn").instantiate()
			e1.img=load(cd[e].i)
			var v=sd[e]
			if v>0:
				e1.txt="+"+str(v)
			else:
				e1.txt=str(v)
			e1.mouse_filter=Control.MOUSE_FILTER_IGNORE
			$tcont/vb.add_child(e1)
func _ready():
	$tcont/img_layer_cont.show()
	#gm.set_font(gm.cur_font,theme)
	pass#upd_stats()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if gm.cur_font!=theme.default_font["resource_name"]:
	#	gm.set_font(gm.cur_font,theme)
	if disabled==true and $tcont/vb.visible or text!="":
		$tcont/vb.hide()
	elif disabled==false and $tcont/vb.visible==false:
		$tcont/vb.show()
func _on_button_down():
	#ps.status=st
	var bid=get_index()
	if shop==0 and fnc.i_search(map.map_execptions,bid)==-1 and boss.is_empty():
		map._upd_items_values()
	if fnc.i_search(map.map_execptions,bid)==-1 and shop==0:
		fnc.get_hero().add_stats=sd
		map.map_execptions.append(bid)
		##
		var dic={}
		var ids=0
		for b in boss:
			dic.merge({ids:{"name":b,"die":false}})
			ids+=1
		##
		get_tree().current_scene.cur_boss=dic
		get_tree().current_scene.exit=exit
		get_tree().current_scene.show_lvls(false)
		get_tree().current_scene.cur_enemys=gm.maps[get_tree().current_scene.lvl].enemys.duplicate()
		get_tree().current_scene.start_game()
		
	if shop==1 and map.posid==bid:
		#get_tree().current_scene.ivent_queue.append(gm.ivents.shop)
		
		map.emit_signal("in_shop")
	map.posid=bid
	map.upd(bid)
	if shop==2:
		get_tree().current_scene.cur_enemys=gm.maps[get_tree().current_scene.lvl].enemys.duplicate()#enemys
		get_tree().current_scene.show_lvls(false)
		get_tree().current_scene.start_game()
		map.map_execptions.append(bid)
		shop=1
		$tcont/img_layer_cont.imgs_paths.clear()
		$tcont/img_layer_cont.imgs_paths.append(gm.images.icons.other.money)
		$tcont/img_layer_cont._upd_()
	if map.max_column<bid%map.colums:
		map.max_column=bid%map.colums
func vls():
	return int($tcont.size.y/float($tcont/vb.get_child(0).size.y+$tcont/vb.get("theme_override_constants/v_separation")))
@onready var stats_cont=$tcont/vb
@onready var stats_tcont=$tcont
func _on_vs_value_changed(value):
	var t=(stats_cont.size.y*stats_cont.scale.y)/(stats_tcont.size.y*stats_tcont.scale.y)
	if t>1.0:
		stats_cont.position.y=(stats_tcont.size.y*stats_tcont.scale.y-stats_cont.size.y*stats_cont.scale.y)*(value)
	else:stats_cont.position.y=0
