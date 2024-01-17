extends Button
@export var arena_scene:PackedScene
@export var actions_queue:Array[empty_node]
@export_range(0,99,1,"or_greater","suffix:stat") var rand_from:int
@export_range(0,99,1,"or_greater","suffix:stat") var rand_to:int
@onready var current_stats_count=fnc.rnd.randi_range(rand_from,rand_to)
@onready var current_stat_list:PackedStringArray
var have:PackedStringArray
func _ready():
	if current_stat_list.is_empty():
		var temp:=PackedStringArray([])
		for e in gm.objs.player.stats.keys():
			temp.append(e)
		return temp
	for e in actions_queue:
		if e is arena_action:
			have.append("fight")
		if e is shop_action:
			have.append("shop")
		if e is empty_node:
			have.append("empty")
func upd_data():pass
