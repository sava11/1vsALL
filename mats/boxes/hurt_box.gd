extends Area2D
@export var m_he=1: set = s_m_h
var he=m_he: set = set_he
@export var tspeed:float=1.0
@onready var t=$Timer
var invi=false: set = set_invi
signal invi_started
signal invi_ended


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
func _ready():
	self.he=m_he
	$Timer.wait_time=tspeed

func set_invi(v):
	invi=v
	if invi==true:
		emit_signal("invi_started")
	else:
		emit_signal("invi_ended")

func start_invi(dir):
	self.invi=true
	t.start(dir)
func _on_Timer_timeout():
	self.invi=false
func _on_hurt_box_invi_ended():
	set_deferred("monitorable",true)
	set_deferred("monitoring",true)
func _on_hurt_box_invi_started():
	set_deferred("monitorable",false)
	set_deferred("monitoring",false)


func _on_area_entered(area):
	set_he(he-area.damage*area.scale_damage)
