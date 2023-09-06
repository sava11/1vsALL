extends Control
@export var imgs_paths:PackedStringArray
@export var img_size:Vector2=Vector2(24,24)
@export var hided_imgs:PackedInt32Array
func validate_img(img:String):
	var imgage=load(img)
	if imgage==null:
		imgage=load(gm.images.undef)
	return imgage
func _upd_():
	for e in get_children():e.free()
	var w=size.x/(img_size.x*imgs_paths.size())
	for e in range(imgs_paths.size()):
		var tr=TextureRect.new()
		tr.texture=validate_img(imgs_paths[e])
		var size_x=((img_size.x*w)*e-(img_size.x-(img_size.x*w)))
		var hided=fnc.i_search(hided_imgs,e)!=-1
		tr.position.x=size_x*int(!hided)
		tr.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		tr.custom_minimum_size=img_size
		if hided:tr.hide()
		add_child(tr)
		tr.name=str(tr.get_index())
	if get_child_count()>0:
		custom_minimum_size=get_child(imgs_paths.size()-1).position+get_child(imgs_paths.size()-1).size
		size=custom_minimum_size
		anchors_preset=6
func _ready():
	_upd_()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
