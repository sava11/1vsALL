extends Area2D
@export var m_he=1: set = s_m_h
var he=m_he: set = set_he
@export var tspeed:float=1.0
@export_range(0,99999) var life_time_period:float=2
@onready var t=$t

signal no_he
signal h_ch(v)
signal m_h_ch(v)
func s_m_h(v):
	m_he=v
	self.he=min(he,m_he)
	emit_signal("m_h_ch",m_he)
func set_he(value):
	he=value
	emit_signal("h_ch",he)
	if he<=0:
		emit_signal("no_he")
		he=0
		delete()
func _ready():
	m_he=fnc._with_dific(m_he,get_tree().current_scene.dif)
	self.he=m_he
	$t.start(life_time_period)
	
func _on_area_entered(area):
	var dmg=area.damage
	if fnc._with_chance(area.crit_chance):
		dmg+=area.crit_damage
		var crit=preload("res://mats/font/crit.tscn").instantiate()
		get_tree().current_scene.ememys_path.add_child(crit)
		crit.position=global_position+Vector2(-crit.size.x/2,-40)
	set_he(he-dmg)

func _process(delta):
	$time.value=$t.time_left
	$time.max_value=life_time_period
	$hp.value=he
	$hp.max_value=m_he
func delete():
	get_parent().stoped=false
	get_parent().get_parent().get_parent().get_node("hurt_box").set_deferred("monitoring",true)
	get_parent().get_parent().get_parent().get_node("hurt_box").set_deferred("monitorable",true)
	queue_free()
