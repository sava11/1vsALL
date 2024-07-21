extends TextureRect
@export var items:Array[shop_item]
@export var item_count:=4
# Called when the node enters the scene tree for the first time.
func _ready():
	for item in items:
		for e in item.statuses:
			if e is random_ingame_status:
				var step_:float=1
				for i in range(e.step):
					step_*=0.1
				var val=0
				if e.step==0:
					if fnc._with_chance(e.e.positive_chance):
						val=fnc.rnd.randi_range(e.p_value_from,e.p_value_to)
					else:
						val=fnc.rnd.randi_range(e.n_value_from,e.n_value_to)
				else:
					if fnc._with_chance(e.positive_chance):
						val=snapped(fnc.rnd.randf_range(e.p_value_from,e.p_value_to),step_)
					else:
						val=snapped(fnc.rnd.randf_range(e.n_value_from,e.n_value_to),step_)
				e.value=val
			#if e is ingame_status:
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
