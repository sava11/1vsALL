extends Node

var sn={}
var fname:="save"
const suffix=".json"
var save_path:="saves"
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)

enum dificulty{easy,norm,hard}
enum gameplay_type{clasic,bossrush,inf,train}
var cur_gameplay_type=gameplay_type.clasic
var cur_dif=dificulty.norm
enum ivents{none,arena,upg_arena,boss_arena,stats_map,shop}
var cur_font="Puzzle-Tale-Pixel"
const fonts={
	"Puzzle-Tale-Pixel":{
		"scn":"res://mats/font/Puzzle-Tale-Pixel-Regular.ttf"
		}
	}
	
func set_font(font:String,theme:Theme):
	theme.default_font=FontVariation.new()
	if cur_font=="Puzzle-Tale-Pixel":
		theme.default_font.base_font=preload("res://mats/font/Puzzle-Tale-Pixel-Regular.ttf")
	if cur_font=="zx spectrum-7":
		theme.default_font.base_font=preload("res://mats/font/zx_spectrum-7.ttf")

func get_cur_lvl():
	return get_tree().current_scene.lvl

const images={
	"undef":"res://mats/imgs/icons/X.png",
	"icons":{
		"charters":{
			"sk_sw":"res://mats/imgs/icons/skelV1.png",
			"sk_sw_u":"res://mats/imgs/icons/skelV1_up.png",
			"sk_bo":"res://mats/imgs/icons/skel_bow.png",
			"sk_bo_u":"res://mats/imgs/icons/skel_bow_up.png",
			"skelvas":"res://mats/imgs/icons/skel_boss.png",
			"skelgener":"res://mats/imgs/icons/skel_boss.png",
			"player":"res://mats/imgs/icons/Warrior Icon.png",
			},
		"stats":{
			"hp":"res://mats/imgs/icons/skills/hp.png",
			"hp_regen":"res://mats/imgs/icons/skills/hp_regeneration.png",
			"dmg":"res://mats/imgs/icons/skills/att.png",
			"crit_dmg":"res://mats/imgs/icons/skills/crit_dmg.png",
			"%crit_dmg":"res://mats/imgs/icons/skills/%crit.png",
			#"+%att_speed":"res://mats/imgs/icons/skills/+%sp_att.png",
			"def":"res://mats/imgs/icons/skills/def.png",
			"max_stamina":"res://mats/imgs/icons/skills/max_stamina.png",
			"regen_stamina_point":"res://mats/imgs/icons/skills/stamina_regen.png",
			"%sp":"res://mats/imgs/icons/skills/speed.png",
			"take_area":"res://mats/imgs/icons/skills/take.png",
		},
		"other":{
			"money":"res://mats/imgs/icons/money.png",
			"aim":"res://mats/imgs/icons/aimed.png",
			"lvl_exit":"res://mats/imgs/icons/icon green arrow.png",
			"boss_crown1":"res://mats/imgs/icons/crown.png",
		}
	}
}
var enemys={
	"sk_sw":{
		"s":"res://mats/enemys/e1/enemy.tscn",
		"i":images.icons.charters.sk_sw,
		"ui":images.icons.charters.sk_sw_u,
		},
	"sk_bo":{
		"s":"res://mats/enemys/e2/enemy.tscn",
		"i":images.icons.charters.sk_bo,
		"ui":images.icons.charters.sk_bo_u,
		},
	"gob_be":{
		"s":"res://mats/enemys/e3/enemy.tscn",
		"i":images.undef,
		"ui":images.undef,
		},
	"gob_range":{
		"s":"res://mats/enemys/e4/enemy.tscn",
		"i":images.undef,
		"ui":images.undef,
		},
	"cultist":{
		"s":"res://mats/enemys/e5/enemy.tscn",
		"i":images.undef,
		"ui":images.undef,
		},
}

var bosses={
	"skelvas":{
		"s":"res://mats/enemys/b2/enemy.tscn",
		"i":images.icons.other.boss_crown1,
		"dificulty_lvl":{
			dificulty.easy:{
				"/attack.active":true,
				"/attack2.active":false,
				"/summon.active":true,
			},
			dificulty.norm:{
				"/attack.active":true,
				"/attack2.active":true,
				"/summon.active":true,
			},
		}
	},
	"skelgener":{
		"s":"res://mats/enemys/b3/enemy.tscn",
		"i":images.icons.other.boss_crown1,
		"dificulty_lvl":{
			dificulty.easy:{
				"/attack.active":true,
				"/hurt_box/healing.active":false,
			},
			dificulty.norm:{
				"/attack.active":true,
				"/hurt_box/healing.active":true,
			},
		}
	},
	"gobbst":{
		"s":"res://mats/bosses/gob_beast/boss.tscn",
		"i":images.icons.other.boss_crown1
	},
	"necromancer":{
		"s":"res://mats/enemys/b5/enemy.tscn",
		"i":images.icons.other.boss_crown1,
		"dificulty_lvl":{
			dificulty.easy:{
				"/attack.active":true,
				"/summon.active":true,
				"/summon2.active":false,
			},
			dificulty.norm:{
				"/attack.active":true,
				"/summon.active":true,
				"/summon2.active":true,
			},
		}
	},
	"fire_women":{
		"s":"res://mats/enemys/b4/enemy.tscn",
		"i":images.icons.other.boss_crown1,
		"dificulty_lvl":{
			dificulty.easy:{
				"/attack.active":false,
				"/summon.active":true,
			},
			dificulty.norm:{
				"/attack.active":true,
				"/summon.active":true,
			},
		}
	},
}
var arenas={
	"train":{
		"t1":"res://mats/lvls/lvl1/lvl1.tscn"
	},
	"l1":{
		"a1":"res://mats/lvls/lvl1/lvl1.tscn",
		"a2":"res://mats/lvls/lvl1/lvl1_1.tscn",
		"a3":"res://mats/lvls/lvl1/lvl1_2.tscn",
	},
	"l2":{
		"a1":"res://mats/lvls/lvl2/lvl2.tscn",
		"a2":"res://mats/lvls/lvl2/lvl2_1.tscn",
		"a3":"res://mats/lvls/lvl2/lvl2_2.tscn",
	},
	"l3":{
		"a1":"res://mats/lvls/lvl3/lvl3_2.tscn",
		"a2":"res://mats/lvls/lvl3/lvl3_1.tscn",
	}
}
var bossrush={
	0:{
		"bosses":PackedStringArray(["skelvas"]),
		"boss_arena":{
				0:{
					"l":arenas.l1.a1,
					"color":Color(50,200,50),
					"%":0.2
				},
				1:{
					"l":arenas.l1.a2,
					"color":Color(50,200,90),
					"%":0.65
				},
				2:{
					"l":arenas.l1.a3,
					"color":Color(50,200,90),
					"%":0.15
				}
			},
		},
	1:{
		"bosses":PackedStringArray(["skelgener"]),
		"boss_arena":{
				0:{
					"l":arenas.l1.a1,
					"color":Color(50,200,50),
					"%":0.2
				},
				1:{
					"l":arenas.l1.a2,
					"color":Color(50,200,90),
					"%":0.65
				},
				2:{
					"l":arenas.l1.a3,
					"color":Color(50,200,90),
					"%":0.15
				}
			},
		},
	2:{
		"bosses":PackedStringArray(["necromancer"]),
		"boss_arena":{
				0:{
					"l":arenas.l1.a1,
					"color":Color(50,200,50),
					"%":0.2
				},
				1:{
					"l":arenas.l1.a2,
					"color":Color(50,200,90),
					"%":0.65
				},
				2:{
					"l":arenas.l1.a3,
					"color":Color(50,200,90),
					"%":0.15
				}
			},
		},
	3:{
		"bosses":PackedStringArray(["fire_women"]),
		"boss_arena":{
				0:{
					"l":arenas.l1.a1,
					"color":Color(50,200,50),
					"%":0.2
				},
				1:{
					"l":arenas.l1.a2,
					"color":Color(50,200,90),
					"%":0.65
				},
				2:{
					"l":arenas.l1.a3,
					"color":Color(50,200,90),
					"%":0.15
				}
			},
		},
}
var maps={
		-1:{"locs":{
				0:{
					"l":arenas.train.t1,
					"color":Color(50,200,50),
					"%":1
				},
			},
			"lvl_color":{
				"normal":{"bg":Color("c29644"),"brd":Color("f0c986")},
				"pressed":{"bg":Color("a07a33"),"brd":Color("dc7938")},
				"hover":{"bg":Color("a07a33"),"brd":Color("c29600")},
				"disabled":{"bg":Color("8f6e00"),"brd":Color("bf9443")},
				},
			"ecount":Vector2(4,8),
			"bosses":PackedStringArray([]),
			"panel":{"bg":Color("8f6F50"),"brd":Color("bf9443")},
			"boss_arena":{
					0:{
						"l":arenas.train.t1,
						"%":1
					},
					
				},
			"enemys":{
				"sk_sw":1,
			}
		},
		0:{
			
			"locs":{
				0:{
					"l":arenas.l1.a1,
					"color":Color(50,200,50),
					"%":0.2
				},
				1:{
					"l":arenas.l1.a2,
					"color":Color(50,200,90),
					"%":0.15
				},
				2:{
					"l":arenas.l1.a3,
					"color":Color(50,200,90),
					"%":0.65
				}
			},
			"lvl_color":{
				"normal":{"bg":Color("c29644"),"brd":Color("f0c986")},
				"pressed":{"bg":Color("a07a33"),"brd":Color("dc7938")},
				"hover":{"bg":Color("a07a33"),"brd":Color("c29600")},
				"disabled":{"bg":Color("8f6e00"),"brd":Color("bf9443")},
				},
			"ecount":Vector2(8,12),
			"bosses":PackedStringArray(["skelvas"]),
			"panel":{"bg":Color("8f6F50"),"brd":Color("bf9443")},
			"boss_arena":{
					0:{
						"l":arenas.l1.a2,
						"%":1
					},
					
				},
			"enemys":{
				"sk_sw":0.9,
				"sk_bo":0.1,
			}
		},
		1:{
			"locs":{
				0:{
					"l":arenas.l2.a1,
					"color":Color(50,200,50),
					"%":0.5
				},
				1:{
					"l":arenas.l2.a2,
					"%":0.35
				},
				2:{
					"l":arenas.l2.a3,
					"%":0.15
				}
			},
			"ecount":Vector2(8,15),
			"bosses":PackedStringArray(["skelvas","necromancer"]),
			"panel":{"bg":Color("8f6eA0"),"brd":Color("bf9443")},
			"boss_arena":{
					0:{
						"l":arenas.l1.a2,#вход в гору
						"%":1.0
					}
				},
			"enemys":{
				"sk_sw":0.85,
				"sk_bo":0.15,
			}
		},
		2:{#Гора
			"locs":{
				0:{
					"l":arenas.l3.a1,
					"color":Color(50,200,50),
					"%":0.9
				},
				1:{
					"l":arenas.l3.a2,
					"color":Color(50,200,50),
					"%":0.1
				}
			},
			"ecount":Vector2(8,15),
			"bosses":PackedStringArray(["skelgener"]),
			"panel":{"bg":Color("8f6eA0"),"brd":Color("bf9443")},
			"boss_arena":{
					0:{
						"l":arenas.l1.a2,
						"%":1.0
					}
				},
			"enemys":{
				"sk_sw":0.5,
				"gob_be":0.2,
				"gob_range":0.3
			}
		},
		3:{
			"locs":{
				0:{
					"l":arenas.l3.a1,
					"color":Color(50,200,50),
					"%":1
				}
			},
			"ecount":Vector2(8,15),
			"bosses":PackedStringArray(["fire_women"]),
			"panel":{"bg":Color("8f6eA0"),"brd":Color("bf9443")},
			"boss_arena":{
					0:{
						"l":arenas.l1.a2,#выход из горы
						"%":1.0
					}
				},
			"enemys":{
				"sk_sw":0.75,
				"gob_be":0.25,
			}
		},
		4:{
			"locs":{
				0:{
					"l":arenas.l3.a2,
					"color":Color(50,200,50),
					"%":1
				}
			},
			"ecount":Vector2(8,15),
			"bosses":PackedStringArray([]),
			"panel":{"bg":Color("8f6eA0"),"brd":Color("bf9443")},
			"boss_arena":{
					0:{
						"l":arenas.l1.a2,
						"%":1.0
					}
				},
			"enemys":{
				"sk_sw":0.1,
				"sk_bo":0.1,
				"gob_be":0.2,
				"gob_range":0.4,
				#"cultist":0.2
			}
		}
		
	}

var game_stats={
	"%spawn_elite":{
			"v":Vector2(0.01,0.1),
			"min_v":0.01,
			"i":images.icons.charters.sk_sw,
			"t":tr("%SPAWN_ELITE")
			},
}
#var cur_gm_stats={}
var player_data={
	"in_action":false,
	"stats":{
		"hp":3.0,
		"hp_rgen":0.1,
		"max_stamina":1.5,
		"regen_stamina_point":0.3,
		"def":1.2,
		"dmg":1.2,
		"crit_dmg":7,
		"%crit_dmg":0.2,
		#"+%att_speed":0.3,
		"run_speed":90,
		"roll_speed":140,
		#"%sp":0,
		"take_area":10
		},
	"prefs":{
		"cur_hp":3000000.0,
		"cur_stm":3000000.0,
		"money":0,
		"do_roll_cost":1,
		"max_exp_start":40,
		"max_exp_sc":1,
		"run_scale":1,
		"roll_timer":0.4,
		"roll_scale":1
		},
}
var game_prefs={
	"dif":0,
	"elite_chance":0.01,
	"boss_elite_chance":0.01,
}

func save_data():
	return {
		str(get_path()):{
			"player_data":player_data,
			"game_prefs":game_prefs
			#"player_pos":str(get_tree().current_scene.get_node("cl/pause").current_pos.get_path())
		}
	}
func load_data(n:Dictionary):
	player_data=n.player_data
	game_prefs=n.game_prefs

func _ready():
	connect("save_data_changed",Callable(gm,"_save_node"))
	connect("_load_data",Callable(gm,"_load_node"))
	if !sn.has(str(get_path())):
		emit_signal("save_data_changed",save_data())
	else:
		emit_signal("_load_data",self,str(get_path()))
	DirAccess.make_dir_absolute(save_path)
	add_to_group("SN")
	upd_objs()
	await  get_tree().process_frame
	#save_file_data()
	load_file_data()

var objs={}
func upd_objs():
	objs={
	"player":{
			"name":"Warrior",
			"stats":{
				"hp":3,
				"hp_rgen":0.1,
				"max_stamina":1.5,
				"regen_stamina_point":0.3,
				"def":1.2,
				"dmg":1.2,
				"crit_dmg":7,
				"%crit_dmg":0.2,
				#"+%att_speed":0.3,
				"run_speed":90,
				"roll_speed":140,
				#"%sp":0,
				"take_area":10
				},
			"prefs":{
				"cur_hp":3000000,
				"do_roll_cost":1,
				"max_exp_start":40,
				"max_exp_sc":1,
				"run_scale":1,
				"roll_timer":0.4,
				"roll_scale":1
				},
	},
	"stats":{
		#"%sp":{
		#	"v":{
		#		0:{"v":{"x":0.005,"y":0.01},"%":0.5,},
		#		1:{"v":{"x":0.05,"y":0.1},"%":0.35,},
		#		2:{"v":{"x":0.11,"y":0.3},"%":0.10,},
		#		3:{"v":{"x":0.3,"y":0.4},"%":0.05,},
		#		},
		#	"-v":{
		#		0:{"v":{"x":-0.5,"y":-0.45},"%":0.5,},
		#		1:{"v":{"x":-0.4,"y":-0.3},"%":0.35,},
		#		2:{"v":{"x":-0.3,"y":-0.35},"%":0.10,},
		#		3:{"v":{"x":-0.1,"y":-0.25},"%":0.05,},
		#		},
		#	"min_v":-0.5,
		#	"i":images.icons.stats["%sp"],
		#	"t":tr("%SPEED"),
		#	"price":120
		#	},
		#"do_roll_cost":{
		#	"v":Vector2(0.2,0.5),
		#	"i":"res://mats/imgs/icons/skills/rolls.png",
		#	"t":tr("MAX_STAMINA_VALUE")
		#	},
		#"+%att_speed":{
		#	"v":Vector2(0.005,0.01),
		#	"-v":Vector2(-0.005,-0.01),
		#	"min_v":0.2,
		#	"i":images.icons.stats["+%att_speed"],
		#	"t":tr("%ATT_SPEED")
		#	},
		"run_speed":{
			"v":{
				0:{"v":{"x":1,"y":2},"%":0.5,},
				1:{"v":{"x":2,"y":5},"%":0.35,},
				2:{"v":{"x":6,"y":9},"%":0.10,},
				3:{"v":{"x":10,"y":14},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-1,"y":-2},"%":0.5,},
				1:{"v":{"x":-2,"y":-7},"%":0.35,},
				2:{"v":{"x":-7,"y":-10},"%":0.10,},
				3:{"v":{"x":-10,"y":-13},"%":0.05,},
				},
			"min_v":50,
			"i":images.icons.stats["%sp"],
			"t":tr("%SPEED"),
			"ct":tr("C%SPEED"),
			"price":2.5
			},
		"hp":{
			"v":{
				0:{"v":{"x":1,"y":1.5},"%":0.5,},
				1:{"v":{"x":1.5,"y":2},"%":0.35,},
				2:{"v":{"x":2,"y":3},"%":0.10,},
				3:{"v":{"x":3,"y":4},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-1,"y":-1.5},"%":0.5,},
				1:{"v":{"x":-1.5,"y":-2},"%":0.35,},
				2:{"v":{"x":-2,"y":-3},"%":0.10,},
				3:{"v":{"x":-3,"y":-4},"%":0.05,},
				},
			"min_v":1,
			"i":images.icons.stats.hp,
			"t":tr("HP"),
			"ct":tr("CHP"),
			"price":3.5
			},
		"hp_rgen":{
			"v":{
				0:{"v":{"x":0.001,"y":0.005},"%":0.5,},
				1:{"v":{"x":0.005,"y":0.008},"%":0.35,},
				2:{"v":{"x":0.008,"y":0.01},"%":0.10,},
				3:{"v":{"x":0.1,"y":0.15},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-0.001,"y":-0.005},"%":0.5,},
				1:{"v":{"x":-0.005,"y":-0.008},"%":0.35,},
				2:{"v":{"x":-0.008,"y":-0.01},"%":0.10,},
				3:{"v":{"x":-0.1,"y":-0.15},"%":0.05,},
				},
			"min_v":0,
			"i":images.icons.stats.hp_regen,
			"t":tr("HP_REGEN"),
			"ct":tr("CHP_REGEN"),
			"price":4
			},
		"dmg":{
			"v":{
				0:{"v":{"x":0.5,"y":1.0},"%":0.5,},
				1:{"v":{"x":1,"y":1.3},"%":0.35,},
				2:{"v":{"x":1.3,"y":1.5},"%":0.10,},
				3:{"v":{"x":2,"y":3},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-0.8,"y":-0.95},"%":0.5,},
				1:{"v":{"x":-0.95,"y":-1.2},"%":0.35,},
				2:{"v":{"x":-1.2,"y":-1.5},"%":0.10,},
				3:{"v":{"x":-1.5,"y":-2.2},"%":0.05,},
				},
			"min_v":0,
			"i":images.icons.stats.dmg,
			"t":tr("DMG"),
			"ct":tr("CDMG"),
			"price":5
			},
		"crit_dmg":{
			"v":{
				0:{"v":{"x":0.8,"y":1},"%":0.5,},
				1:{"v":{"x":1,"y":1.3},"%":0.35,},
				2:{"v":{"x":1.3,"y":1.55},"%":0.10,},
				3:{"v":{"x":1.55,"y":2.2},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-0.75,"y":-0.95},"%":0.5,},
				1:{"v":{"x":-0.95,"y":-1.5},"%":0.35,},
				2:{"v":{"x":-1.5,"y":-2},"%":0.10,},
				3:{"v":{"x":-2,"y":-2.7},"%":0.05,},
				},
			"min_v":0,
			"i":images.icons.stats["crit_dmg"],
			"t":tr("CRIT_DMG"),
			"ct":tr("CCRIT_DMG"),
			"price":3.5
			},
		"%crit_dmg":{
			"v":{
				0:{"v":{"x":0.01,"y":0.05},"%":0.5,},
				1:{"v":{"x":0.05,"y":0.08},"%":0.35,},
				2:{"v":{"x":0.08,"y":0.11},"%":0.10,},
				3:{"v":{"x":0.12,"y":0.2},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-0.12,"y":-0.2},"%":0.5,},
				1:{"v":{"x":-0.8,"y":-0.11},"%":0.35,},
				2:{"v":{"x":-0.5,"y":-0.8},"%":0.10,},
				3:{"v":{"x":-0.01,"y":-0.05},"%":0.05,},
				},
			"min_v":0,
			"i":images.icons.stats["%crit_dmg"],
			"t":tr("%CRIT_DMG"),
			"ct":tr("C%CRIT_DMG"),
			"price":4
			},
		"def":{
			"v":{
				0:{"v":{"x":0.6,"y":1},"%":0.5,},
				1:{"v":{"x":1,"y":0.5},"%":0.35,},
				2:{"v":{"x":1.55,"y":2},"%":0.10,},
				3:{"v":{"x":2.1,"y":3},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-1.25,"y":-1.6},"%":0.5,},
				1:{"v":{"x":-0.85,"y":-1.2},"%":0.35,},
				2:{"v":{"x":-0.35,"y":-0.8},"%":0.10,},
				3:{"v":{"x":-0.1,"y":-0.25},"%":0.05,},
				},
			"min_v":1,
			"i":images.icons.stats.def,
			"t":tr("DEF"),
			"ct":tr("CDEF"),
			"price":5.5
			},
		"max_stamina":{
			"v":{
				0:{"v":{"x":1,"y":1.5},"%":0.5,},
				1:{"v":{"x":1.5,"y":2},"%":0.35,},
				2:{"v":{"x":2,"y":3},"%":0.10,},
				3:{"v":{"x":3,"y":4},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-1,"y":-1.5},"%":0.5,},
				1:{"v":{"x":-1.5,"y":-2},"%":0.35,},
				2:{"v":{"x":-2,"y":-3},"%":0.10,},
				3:{"v":{"x":-3,"y":-4},"%":0.05,},
				},
			"min_v":0.5,
			"i":images.icons.stats.max_stamina,
			"t":tr("MAX_STAMINA_VALUE"),
			"ct":tr("CMAX_STAMINA_VALUE"),
			"price":3.2
			},
		"regen_stamina_point":{
			"v":{
				0:{"v":{"x":0.1,"y":0.45},"%":0.5,},
				1:{"v":{"x":0.5,"y":0.67},"%":0.35,},
				2:{"v":{"x":0.68,"y":1},"%":0.10,},
				3:{"v":{"x":1.1,"y":2.5},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-0.46,"y":-0.65},"%":0.5,},
				1:{"v":{"x":-0.31,"y":-0.45},"%":0.35,},
				2:{"v":{"x":-0.15,"y":-0.3},"%":0.10,},
				3:{"v":{"x":-0.05,"y":-0.1},"%":0.05,},
				},
			"min_v":0.1,
			"i":images.icons.stats.regen_stamina_point,
			"t":tr("STAMINA_REGEN_VALUE"),
			"ct":tr("CSTAMINA_REGEN_VALUE"),
			"price":4.2
			},
		"take_area":{
			"v":{
				0:{"v":{"x":1,"y":1.5},"%":0.5,},
				1:{"v":{"x":1.5,"y":2},"%":0.35,},
				2:{"v":{"x":2,"y":3},"%":0.10,},
				3:{"v":{"x":3,"y":4},"%":0.05,},
				},
			"-v":{
				0:{"v":{"x":-1,"y":-1.5},"%":0.5,},
				1:{"v":{"x":-1.5,"y":-2},"%":0.35,},
				2:{"v":{"x":-2,"y":-3},"%":0.10,},
				3:{"v":{"x":-3,"y":-4},"%":0.05,},
				},
			"min_v":10,
			"i":images.icons.stats.take_area,
			"t":tr("COLLECTING"),
			"ct":tr("CCOLLECTING"),
			"price":2.6
			}
		},
	"updates":{
		"agility":{
			"i":images.undef,
			"unlocked":false,
			"t":tr("AGILITY_TEXT"),
			"lvls":{
				0:{
					"stats":{
						"regen_stamina_point":{"x":0.05,"y":0.1},
						"max_stamina":0.01,
						"run_speed":{"x":2,"y":5},
						},
					"rare":Vector2(0,0.5),"value":6
				},
				1:{
					"stats":{
						"regen_stamina_point":{"x":0.1,"y":0.25},
						"max_stamina":0.02,
						"run_speed":{"x":6,"y":9},
						},
					"rare":Vector2(0.5,1),"value":8
					},
				}
			},
		"agility_hp":{
			"i":images.undef,
			"unlocked":false,
			"t":tr("AGILITY-HP_TEXT"),
			"lvls":{
				0:{
					"stats":{
						"hp_rgen":{"x":0.2,"y":0.65},
						"hp":{"x":0.6,"y":1.1},
						"regen_stamina_point":{"x":0.035,"y":0.08},
						"max_stamina":0.03,
						"run_speed":{"x":1,"y":3},
						},
					"rare":Vector2(0,0.5),"value":6
				},
				1:{
					"stats":{
						"hp_rgen":{"x":0.7,"y":1.75},
						"hp":{"x":0.6,"y":1.1},
						"regen_stamina_point":{"x":0.1,"y":0.8},
						"max_stamina":0.03,
						"run_speed":{"x":3,"y":8},
						},
					"rare":Vector2(0.5,1),"value":8
					},
				}
			},
		"agility_def":{
			"i":images.undef,
			"unlocked":false,
			"t":tr("AGILITY-DEF_TEXT"),
			"lvls":{
				0:{
					"stats":{
						"def":{"x":0.15,"y":0.5},
						"regen_stamina_point":{"x":0.035,"y":0.08},
						"max_stamina":0.03,
						"run_speed":{"x":1,"y":3},
						},
					"rare":Vector2(0,0.5),"value":6
				},
				1:{
					"stats":{
						"def":{"x":0.45,"y":0.7},
						"regen_stamina_point":{"x":0.1,"y":0.8},
						"max_stamina":0.03,
						"run_speed":{"x":3,"y":8},
						},
					"rare":Vector2(0.5,1),"value":8
					},
				}
			},
		"hp":{
			"i":images.undef,
			"unlocked":false,
			"t":tr("HP_TEXT"),
			"lvls":{
				0:{
					"stats":{
						"hp_rgen":{"x":0.05,"y":0.1},
						"hp":{"x":0.5,"y":1},
						"dmg":{"x":0.5,"y":1.5},
						},
					"rare":Vector2(0,0.5),"value":7
				},
				1:{
					"stats":{
						"hp_rgen":{"x":0.05,"y":0.1},
						"hp":2,
						"dmg":{"x":1.5,"y":3},
						},
					"rare":Vector2(0.5,1),"value":9
					},
				}
			},
		"hp_agility":{
			"i":images.undef,
			"unlocked":false,
			"t":tr("AGILITY-HP_TEXT"),
			"lvls":{
				0:{
					"stats":{
						"hp_rgen":{"x":0.2,"y":0.65},
						"hp":{"x":0.6,"y":1.1},
						"regen_stamina_point":{"x":0.035,"y":0.08},
						"max_stamina":0.03,
						"run_speed":{"x":1,"y":3},
						},
					"rare":Vector2(0,0.5),"value":6
				},
				1:{
					"stats":{
						"hp_rgen":{"x":0.7,"y":1.75},
						"hp":{"x":0.6,"y":1.1},
						"regen_stamina_point":{"x":0.1,"y":0.8},
						"max_stamina":0.03,
						"run_speed":{"x":3,"y":8},
						},
					"rare":Vector2(0.5,1),"value":8
					},
				}
			},
		"def":{
			"i":images.undef,
			"unlocked":false,
			"t":tr("DEF_TEXT"),
			"lvls":{
				0:{
					"stats":{
						"def":{"x":0.1,"y":0.9},
						"dmg":{"x":0.5,"y":0.9},
						},
					"rare":Vector2(0,0.5),"value":10
				},
				1:{
					"stats":{
						"def":{"x":0.9,"y":1.5},
						"dmg":{"x":1,"y":2},
						},
					"rare":Vector2(0.5,1),"value":14
					},
				}
			},
		"def_hp":{
			"i":images.undef,
			"unlocked":false,
			"t":tr("DEF-HP_TEXT"),
			"lvls":{
				0:{
					"stats":{
						"hp_rgen":{"x":0.025,"y":0.08},
						"hp":{"x":0.25,"y":0.5},
						"def":{"x":0.09,"y":0.5},
						"dmg":{"x":0.3,"y":0.5},
						},
					"rare":Vector2(0,0.5),"value":10
				},
				1:{
					"stats":{
						"hp_rgen":{"x":0.15,"y":0.5},
						"hp":{"x":0.75,"y":1.5},
						"def":{"x":0.6,"y":1.3},
						"dmg":{"x":0.5,"y":1},
						},
					"rare":Vector2(0.5,1),"value":14
					},
				}
			},
		
		#"boots update":{
		#	"i":images.undef,
		#	"unlocked":false,
		#	"t":tr("THE_SWORD_TEXT"),
		#	"lvls":{
		#		0:{"stats":{"regen_stamina_point":Vector2(0.05,0.2),"def":Vector2(0.25,2),"max_stamina":0.01,"run_speed":2},"rare":Vector2(0,0.5),"value":10},
		#		1:{"stats":{"regen_stamina_point":Vector2(0.15,0.3),"def":Vector2(2,2.5),"max_stamina":0.08,"run_speed":5},"rare":Vector2(0.3,0.55),"value":10},
		#		2:{"stats":{"regen_stamina_point":Vector2(0.25,0.4),"def":Vector2(2.5,4),"max_stamina":0.1,"run_speed":10},"rare":Vector2(0.55,0.8),"value":20},
		#		3:{"stats":{"regen_stamina_point":Vector2(0.4,0.5),"def":Vector2(4,5),"max_stamina":0.4,"run_speed":15,"%crit_dmg":0.2},"rare":Vector2(0.8,1),"value":25},
		#		}
		#	},
		#"the sword":{
		#	"i":images.undef,
		#	"unlocked":false,
		#	"t":tr("THE_SWORD_TEXT"),
		#	"lvls":{
		#		0:{"stats":{"dmg":Vector2(1,9),"crit_dmg":1},"rare":Vector2(0,0.5),"value":10},
		#		1:{"stats":{"dmg":2,"$crit_dmg":0.11},"rare":Vector2(0.3,0.55),"value":10},
		#		2:{"stats":{"dmg":6,"crit_dmg":5},"rare":Vector2(0.55,0.8),"value":20},
		#		3:{"stats":{"dmg":10,"crit_dmg":9,"%crit_dmg":0.2},"rare":Vector2(0.8,1),"value":25},
		#		}
		#	},
		#"armor":{
		#	"i":images.undef,
		#	"unlocked":false,
		#	"t":tr("ARMOR_TEXT"),
		#	"lvls":{
		#		0:{"stats":{"def":Vector2(1,1.5)},"rare":Vector2(0,0.05),"value":15},
		#		1:{"stats":{"def":1,"run_speed":0.01},"rare":Vector2(0,0.05),"value":16},
		#		3:{"stats":{"def":4},"rare":Vector2(0.05,0.5),"value":18},
		#		4:{"stats":{"def":8},"rare":Vector2(0.5,1.0),"value":20},
		#		}
		#	},
		#"boots":{
		#	"i":images.undef,
		#	"unlocked":false,
		#	"t":tr("BOOTS_TEXT"),
		#	"lvls":{
		#		0:{"stats":{"run_speed":0.05},"rare":Vector2(0,0.5),"value":30},
		#		4:{"stats":{"run_speed":0.07},"rare":Vector2(0.5,1.0),"value":40},
		#		}
		#	},
		#"item1":{
		#	"i":images.undef,
		#	"unlocked":false,
		#	"t":tr("item1_TEXT"),
		#	"lvls":{
		#		0:{"stats":{"run_speed":0.05,},"rare":Vector2(0,0.5),"value":15},
		#		1:{"stats":{"run_speed":0.07,"hp":2},"rare":Vector2(0.5,1.0),"value":30},
		#		}
		#	},
		#"ZALLE_VOID":{
		#	"i":images.undef,
		#	"unlocked":false,
		#	"t":tr("ZALLE_VOID_TEXT"),
		#	"lvls":{
		#		0:{"stats":{"hp":3,"dmg":-3,"crit_dmg":-1},"rare":Vector2(0,0.1),"value":22},
		#		1:{"stats":{"def":3,"hp":-1,"hp_rgen":0.01},"rare":Vector2(0.2,0.4),"value":35},
		#		}
		#	},
		#"FALLE_VOID":{
		#	"i":images.undef,
		#	"unlocked":false,
		#	"t":tr("FALLE_VOID_TEXT"),
		#	"lvls":{
		#		0:{"stats":{"hp":1.5,"dmg":2,"crit_dmg":-2,"max_stamina":1,"def":-2},"rare":Vector2(0,0.2),"value":23},
		#		1:{"stats":{"hp":2.2,"dmg":3,"crit_dmg":-5,"max_stamina":1.5,"def":-4},"rare":Vector2(0.1,0.2),"value":34},
		#		}
		#	},
	},
	"items":{
		"surikens":{
			"i":images.undef,
			"unlocked":false,
			"t":tr("SURIKEN_TEXT"),
			"scn":"res://mats/items/sur/sur_spawner.tscn",
			"lvls":{
				0:{"stats":{
					"dmg":1,
					"crit_dmg":0,
					"%crit_dmg":0,
					"item_count":3,
					"item_spawn_time":5,
					},
				"rare":Vector2(0,0.5),
				"value":40
				},
			}
		}
	}
}

func get_item(item_name:String,lvl:int):
	var stats=objs.items[item_name].lvls[lvl]
	var s=load(objs.items[item_name].scn).instantiate()
	s.set_stats(stats)
	fnc.get_hero().get_node("lvls").add_child(s)



func save_file_data():
	for e in get_tree().get_nodes_in_group("SN"):
		_save_node(e.save_data())
	var save_game := FileAccess.open(save_path+"/"+fname+suffix, FileAccess.WRITE)
	save_game.store_line(JSON.stringify(sn))
	save_game.close()
func load_file_data():
	if (FileAccess.file_exists(save_path+"/"+fname+suffix)):
		var save_game := FileAccess.open(save_path+"/"+fname+suffix, FileAccess.READ)
		if save_game.get_length()!=0:
			sn=JSON.parse_string(save_game.get_line())
			for e in sn.keys():
				get_node(e).load_data(sn[e])
		else:
			print("save is clear")
		save_game.close()
	else:
		print("save isn't exists")


func _save_node(d:Dictionary):
	sn.merge(d,true)
func _load_node(n,path):
	var d=sn[path]
	n.load_data(d)
