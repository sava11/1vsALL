extends Control
@export_multiline var text:String
@export var viewport_target:Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	var ps=PackedVector2Array([Vector2.ZERO,$l.to_local(viewport_target)])
	$l.points=ps
	$t.text=text
func _on_b_button_down():
	queue_free()
