class_name shop_action extends empty_node
@export var items:Array[shop_item]
@export_group("random item generator")
@export_range(1,99,1,"or_greater") var count_min:int=4:
	set(v):
		if v>count_max:
			count_min=count_max
		else:
			count_min=v
	get:
		return count_min
@export_range(1,99,1,"or_greater") var count_max:int=4: 
	set(v):
		if v<count_min:
			count_max=count_min
		else:
			count_max=v
	get:
		return count_max
@export_range(0,99,0.001,"or_greater")var rarity:float
func _init():
	if rarity>=0 and len(items)==0:
		#ЗАПОЛНЯЕМ СГЕНЕРИРОВАННЫМИ ПРЕДМЕТАМИ
		pass
