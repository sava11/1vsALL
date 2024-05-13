extends Node
@export var scene_to_add:Node
@export var scene_to_func:Node
@export var scene_func:String
@export var hurtbox_path:NodePath="../hurt_box"
@onready var hurtbox=get_node(hurtbox_path)
signal die(n:String)
var bname:String=""
var pb=null
func emit():
	emit_signal("die",bname)
	if is_instance_valid(pb):
		pb.queue_free()
func _ready():
	pb=preload("res://mats/contents/hpBar/pb.tscn").instantiate()
	scene_to_add.add_child.call_deferred(pb)
	connect("die",Callable(scene_to_func, scene_func))
	hurtbox.connect("h_ch",Callable(self,"set_value"))
	await get_tree().process_frame
	pb.max_value=hurtbox.m_he
func set_value(h):
	if is_instance_valid(pb):
		pb.value=h
