extends Panel
var sd={}
@export var item_name:String=""
var value:int=0
var lvl=0
var del_name
# Called when the node enters the scene tree for the first time.
func load_item(item_name:String):
	sd=gm.objs.updates[item_name]
	match lvl:
		0:get("theme_override_styles/panel").bg_color=Color(0,0,0,0.5)
		1:get("theme_override_styles/panel").bg_color=Color(0,0,0.5,0.5)
		#2:get("theme_override_styles/panel").bg_color=Color(0,0.5,0,0.5)
		2:get("theme_override_styles/panel").bg_color=Color(0.5,0,0.5,0.5)
		3:get("theme_override_styles/panel").bg_color=Color(0,0.5,0.5,0.5)
		4:get("theme_override_styles/panel").bg_color=Color(0.6,0.5,0,0.5)
	#sd.merge({n:v},true)
	$img.texture=load(sd.i)
	$txt.text=tr(sd.t)
	$buy.text=str(value)
	for e in sd["lvls"][lvl].stats:
		var e1=preload("res://mats/UI/map/elems.tscn").instantiate()
		var n=gm.objs.stats[e]
		e1.img=load(n.i)
		e1.txt=str(sd["lvls"][lvl].stats[e])
		e1.popup_text=n.t
		$cont/tcont/c.add_child(e1)
		#e1.img=load(cd[e].i)

func _ready():
	load_item(item_name)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$buy.disabled=!fnc.get_hero().money>=value
	pass


func _on_vs_value_changed(value):
	$cont/tcont/c.position.y=($cont/tcont.size.y*$cont/tcont.scale.y-$cont/tcont/c.size.y*$cont/tcont/c.scale.y/2)*(value)


func _on_button_down():
	fnc.get_hero().money-=value
	if fnc.get_hero().inv.has(item_name+"/"+str(lvl)):
		fnc.get_hero().inv[item_name+"/"+str(lvl)].count+=1
	else:
		fnc.get_hero().inv.merge({item_name+"/"+str(lvl):{"stats":sd["lvls"][lvl],"count":1}})
	fnc.get_hero().add_stats=sd["lvls"][lvl].stats
	fnc.get_hero().merge_stats()
	get_parent().get_parent().get_parent().upd_stats()
	get_parent().get_parent().get_parent().shop_items[get_parent().get_parent().get_parent().posid].erase(del_name)
	queue_free()
	pass # Replace with function body.
