extends TextureRect
var stats={}
@export var item_name:String=""
var value:int=0
var lvl=0
var del_name
# Called when the node enters the scene tree for the first time.
func load_item(item_name:String):
	var sd=gm.objs.updates[item_name].duplicate(true)
	#match lvl:
		#0:get("theme_override_styles/panel").bg_color=Color(0,0,0,0.5)
		#1:get("theme_override_styles/panel").bg_color=Color(0,0,0.5,0.5)
		#2:get("theme_override_styles/panel").bg_color=Color(0,0.5,0,0.5)
		#2:get("theme_override_styles/panel").bg_color=Color(0.5,0,0.5,0.5)
		#3:get("theme_override_styles/panel").bg_color=Color(0,0.5,0.5,0.5)
		#4:get("theme_override_styles/panel").bg_color=Color(0.6,0.5,0,0.5)
	#sd.merge({n:v},true)
	$img.texture=load(sd.i)
	$txt.text=tr(sd.t)
	$buy.text=str(value)
	
	for e in stats:
		var e1=preload("res://mats/UI/map/elems.tscn").instantiate()
		var n=gm.objs.stats[e]
		e1.img=load(n.i)
		e1.txt=str(stats[e])
		e1.popup_text=n.t
		$cont/tcont/c.add_child(e1)
		#e1.img=load(cd[e].i)

func _ready():
	load_item(item_name)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$buy.disabled=!gm.player_data.stats.money>=value
	
	pass


@onready var stats_cont=$cont/tcont/c
@onready var stats_tcont=$cont/tcont
func _on_vs_value_changed(value):
	var t=(stats_cont.size.y*stats_cont.scale.y)/(stats_tcont.size.y*stats_tcont.scale.y)
	if t>1.0:
		stats_cont.position.y=(stats_tcont.size.y*stats_tcont.scale.y-stats_cont.size.y*stats_cont.scale.y)*(value)
	else:stats_cont.position.y=0


func _on_button_down():
	gm.player_data.other.money-=value
	fnc.get_hero().add_stats=stats
	fnc.get_hero().merge_stats()
	get_parent().get_parent().get_parent().upd_stats()
	get_parent().get_parent().get_parent().shop_items[get_parent().get_parent().get_parent().posid].erase(del_name)
	queue_free()
	pass # Replace with function body.
