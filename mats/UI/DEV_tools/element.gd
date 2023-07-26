extends VBoxContainer
@export var text:String
@export var to:NodePath
@export var function:String
@export var with_spinbox:bool=false
@export var min:float=-1
@export var max:float=1
var value:int=0

func _ready():
	if with_spinbox==false:
		$sb.queue_free()
	else:
		$sb.max_value=max
		$sb.min_value=min
		#$sb.value=min
	if function!="":
		if get_node_or_null(to)!=null:
			var t=Callable(get_node(to),function)
			$txt/bcont/b.connect("button_down",t)
		else:
			var t=Callable(self,function)
			$txt/bcont/b.connect("button_down",t)
	$txt/t.text=text

func _on_spin_box_value_changed(v):
	value=v
	$sb.get_line_edit().release_focus()
