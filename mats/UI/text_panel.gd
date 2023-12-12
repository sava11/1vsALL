extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	gm.set_font(gm.cur_font,theme)
	pass # Replace with function body.

var been_in:bool=false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Geometry2D.is_point_in_polygon(get_global_mouse_position(),PackedVector2Array([
		global_position,
		global_position+size*Vector2(1,0)*scale,
		global_position+size*scale,
		global_position+size*Vector2(0,1)*scale,
	])) and been_in:queue_free()


func _on_mouse_entered():
	been_in=true
