extends RigidBody2D
@export var rast=85
@export var dmg_area_ang=5
@export var dmg_from:float=1
@export var dmg_to:float=2
@export var crit_dmg_from:float=1
@export var crit_dmg_to:float=2
@export var speed=60

# Called when the node enters the scene tree for the first time.
func _ready():
	var pol:PackedVector2Array=PackedVector2Array([])
	var dots=3
	var ang=dmg_area_ang/dots
	for e in range (dots):
		pol.append(fnc.move(ang*e-dmg_area_ang/2)*rast)
	pol.append(Vector2(0,4))
	pol.append(Vector2(0,-4))
	for e in $dmgs.get_children():
		e.get_node("c").polygon=pol
		e.damage=fnc._with_dific(gm.rnd.randf_range(dmg_from,dmg_to),get_tree().current_scene.get("dif"))
		e.crit_damage=fnc._with_dific(gm.rnd.randf_range(crit_dmg_from,crit_dmg_to),get_tree().current_scene.get("dif"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_degrees+=speed*delta
	for e in $dmgs.get_children():
		e.get_node("cp").gravity=fnc.move(e.rotation_degrees)*196
	pass
