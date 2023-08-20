extends Sprite2D
@export var time_curve:Curve
@export_range(0.0,99999.0) var time:float
@export var load_scene:PackedScene
@export var scene_params:Dictionary={}
var st=0
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time!=0.0 and st<time:
		st+=delta
		self_modulate.a=time_curve.sample_baked(st/time)
	else:
		var itm=load_scene.instantiate()
		itm.global_position=global_position
		for e in scene_params.keys():
			if itm.get(e)!=null:
				itm.set(e,scene_params[e])
		get_parent().add_child(itm)
		queue_free()
	pass
