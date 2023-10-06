extends Area2D
@export var dmg_from:float=1
@export var dmg_to:float=2
@export var crit_dmg_from:float=1
@export var crit_dmg_to:float=2
@export var shadow:Color
@export_range(1,999999) var time_step_from:float=3.0
@export_range(1,999999) var time_step_to:float=4.0
@export_enum("circle","rect","poly") var zone_type:int=0
@export_range(1,9999999) var radius:float=20
@export var rect:Vector2=Vector2(10,10)
@export var polygon:PackedVector2Array=[Vector2(-10,10),Vector2(10,10),Vector2(10,-10),Vector2(-10,-10)]
var area=null
func try_rand_zone():
	var pos:Vector2
	var p1=min($c.polygon)
	while !Geometry2D.is_point_in_polygon(pos,$c.polygon):
		pos
# Called when the node enters the scene tree for the first time.
func _ready():
	area=preload("res://mats/boxes/custom_dmg_area.tscn").instantiate()
	match zone_type:
		0: 
			area.think(radius)
		1: 
			area.think(rect)
		2: 
			area.think(polygon)
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
