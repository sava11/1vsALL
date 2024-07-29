extends Area2D
@export var node_path:NodePath="../"
@export var attack_name:String=""
@export var attack_anim_name:String=""
@export var active:bool=true
@export var drawing=true
@export_range(0,99999) var attack_time_period:float=2.0
@export var by_time:bool=false
@export_range(0,1) var percent:float=1
@export_range(0,999999) var dots:int=6
@export_range(0,999999) var attack_range:float=30
@export_group("attack")
@export var elite_damage_scale:float=1.5
@export_subgroup("damage")
@export var static_damage:bool=false
@export_range(0,999999999) var damage_from:float=1.0
@export_range(0,999999999) var damage_to:float=2.0
@export_subgroup("crit_damage")
@export var static_crit:bool=false
@export_range(0,999999999) var crit_damage_from:float=1.0
@export_range(0,999999999) var crit_damage_to:float=4.0
@export_subgroup("crit_chance")
@export var static_crit_chance:bool=false
@export_range(0.0,1.0) var crit_chance_from:float=0
@export_range(0.0,1.0) var crit_chance_to:float=0
@export_subgroup("position")
@export var pos_from:float=-5
@export var pos_to:float=5
@export_range(-180,180) var angle_from:float=-45
@export_range(-180,180) var angle_to:float=45
var damage=0
var crit_chance=0
var crit_damage=0
var n=null#node
func _what_draw():
	draw_arc(Vector2.ZERO,attack_range,deg_to_rad(angle_to),deg_to_rad(angle_from),30,Color(1.0,0,0,0.5),2,false)
func _draw():
	if active and drawing:
		_what_draw()
func set_att_zone():
	var pol=PackedVector2Array([])
	var tang=abs(angle_from)+abs(angle_to)
	var ang=tang/dots
	if pos_from==pos_to and pos_to==0:
		pol.append(Vector2.ZERO)
	else:
		pol.append(Vector2(0,pos_to))
		pol.append(Vector2(0,pos_from))
	for e in range(dots+1):
		pol.append(fnc.move(e*ang+angle_from)*attack_range)
	$col.polygon=pol
func _ready():
	if active==true:
		n=get_node(node_path)
		if percent>0:
			n.doing_chance_list.merge({attack_name:percent})
		n.statuses.merge({attack_name:attack_anim_name})
		set_att_zone()
		if !static_damage:
			damage=fnc._with_dific(randf_range(damage_from,damage_to),n.dif)
		else:
			damage=damage_from
		if !static_crit_chance:
			crit_chance=fnc._with_dific(randf_range(crit_chance_from,crit_chance_to),n.dif)
		else:
			crit_chance=crit_chance_from
		if !static_damage:
			crit_damage=fnc._with_dific(randf_range(crit_damage_from,crit_damage_to),n.dif)
		else:
			crit_damage=crit_damage_from
		if n.get("elite")!=null:
			crit_damage*=elite_damage_scale
			damage*=elite_damage_scale
	past_ready()
func past_ready():pass
func past_proc(_d:float):pass
var bs=[]
func _physics_process(delta):
	queue_redraw()
	past_proc(delta)
func _on_body_entered(b):
	if b!=self and b.is_in_group("border")==false:
		bs.append(b)
		
func _on_body_exited(b):
	if b!=self and b.is_in_group("border")==false:
		bs.remove_at(fnc.i_search(bs,b))
