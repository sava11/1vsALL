extends Area2D
@export var damage:float=1.0
@export var crit_damage:float=2.0
@export var crit_chance:float=0.0
var obj=null

func think(v):
	if v is PackedVector2Array:
		obj=CollisionPolygon2D.new()
		obj.polygon=v
	elif v is Vector2:
		obj=CollisionShape2D.new()
		obj.shape=RectangleShape2D.new()
		obj.shape.size=v
	elif v is float or v is int:
		obj=CollisionShape2D.new()
		obj.shape=CircleShape2D.new()
		obj.shape.radius=v
	obj.name="c"
	add_child(obj)
func _draw():
	if obj is CollisionPolygon2D:
		draw_polygon(obj.polygon,PackedColorArray([Color(1.0,0,0,0.5)]))
	elif obj is CollisionShape2D:
		if obj.shape is RectangleShape2D:
			draw_rect(Rect2(obj.shape.size-obj.shape.size/2,obj.shape.size),Color(1.0,0,0,0.5),true)
		elif obj.shape is CircleShape2D:
			draw_circle(Vector2.ZERO,obj.shape.radius,Color(1,0,0,0.5))
func _physics_process(delta):
	queue_redraw()
