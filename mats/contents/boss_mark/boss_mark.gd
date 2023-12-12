extends Node
@export var hurtbox_path:NodePath="../hurt_box"
@onready var hurtbox=get_node(hurtbox_path)
signal die(n)
var bname:int=0
var pb=null
func emit():
	emit_signal("die",bname)
	print("sdf")
	if is_instance_valid(pb):
		pb.queue_free()
func _ready():
	pb=preload("res://mats/contents/hpBar/pb.tscn").instantiate()
	get_tree().current_scene.get_node("cl/Control/bpg").add_child.call_deferred(pb)
	connect("die",Callable(get_tree().current_scene, "boss_die"))
	hurtbox.connect("h_ch",Callable(self,"set_value"))
	await get_tree().process_frame
	pb.max_value=hurtbox.m_he
func set_value(_delta):
	if is_instance_valid(pb):
		pb.value=hurtbox.he
