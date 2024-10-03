extends Node
signal darked(result:bool)
signal _load_data(node:Object,path:String)
signal save_data_changed(dict:Dictionary)

var sn:={}
var fname:="save"
const suffix=".json"
var save_path:="saves"

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
		theme.default_font.base_font=preload("res://mats/UI/font/Puzzle-Tale-Pixel-Regular.ttf")
	if cur_font=="zx spectrum-7":
		theme.default_font.base_font=preload("res://mats/UI/font/zx_spectrum-7.ttf")

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
			"rsp":"res://mats/imgs/icons/skills/roll speed.png",
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
const enemys={
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

const bosses={
	"res://mats/enemys/b2/enemy.tscn":{
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
	"res://mats/enemys/b3/enemy.tscn":{
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
	"res://mats/enemys/b5/enemy.tscn":{
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
	"res://mats/enemys/b4/enemy.tscn":{
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

const train_scenario={
	
}
#var cur_gm_stats={}
const start_player_data={
	"in_action":"",
	"deaths":0,
	"runned_lvls":0,
	"stats":{
		"money":0,
		"hp":8.0,
		"hp_regen":0.1,
		"max_stamina":1.5,
		"regen_stamina_point":0.3,
		"def":1,
		"dmg":1,
		"crit_dmg":3,
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
		"do_roll_cost":1,
		"max_exp_start":40,
		"max_exp_sc":1,
		"run_scale":1,
		"roll_timer":0.4,
		"roll_scale":1
		},
}
var player_data=start_player_data.duplicate(true)

func merge_stats(stats:Dictionary):
	for e in stats.keys():
		if player_data.stats.get(e)!=null:
			player_data.stats[e]=clamp(player_data.stats[e]+stats[e],gm.objs.stats[e].min_v,999999999)
const start_game_prefs={
	"seed":-1,
	"bosses_died":0,
	"scripts":{
		"traied":false,
		"message_to_train_accepted":false,
		"lvl1_runned":false,
		"lvl2_runned":false,
		"lvl3_runned":false,
		"lvl4_runned":false,
		"lvl5_runned":false,
		"lvl6_runned":false
		},
	"dif":0,
	"elite_chance":0.01,
	"boss_elite_chance":0.001,
}
var game_prefs=start_game_prefs.duplicate(true)
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
	game_prefs.dif=0
	fnc.rnd.seed=int(game_prefs.seed)
func _ready():
	process_mode=PROCESS_MODE_ALWAYS
	#PhysicsServer2D.set_active(true)
	connect("save_data_changed",Callable(gm,"_save_node"))
	connect("_load_data",Callable(gm,"_load_node"))
	if !sn.has(str(get_path())):
		emit_signal("save_data_changed",save_data())
	else:
		emit_signal("_load_data",self,str(get_path()))
	DirAccess.make_dir_absolute(save_path)
	add_to_group("SN")
	#await get_tree().process_frame

func make_dialog(d:dialog_data):
	if get_tree().current_scene.get_node("cl/dialog")!=null:
		if !d==null:
			get_tree().current_scene.get_node("cl/dialog").show()
			get_tree().current_scene.get_node("cl/dialog").start(d)
		else:
			get_tree().current_scene.get_node("cl/dialog").hide()
			get_tree().current_scene.get_node("cl/dialog").clean_dialog()

var objs={
	"stats":{
		"money":{
			"postfix":"",
			"min_v":0,
			"i":images.icons.other.money,
			"t":"MONEY",
			"ct":"MONEY",
			"step":1
			},
		"roll_speed":{
			"postfix":"",
			"v":{
				0:{"v":{"x":1,"y":2},"%":0,},
				#1:{"v":{"x":2,"y":4},"%":0.1,},
				#2:{"v":{"x":5,"y":6},"%":0.3,},
				#3:{"v":{"x":7,"y":8},"%":0.55,},
				},
			"-v":{
				0:{"v":{"x":-1,"y":-2},"%":0,},
				#1:{"v":{"x":-2,"y":-4},"%":0.2,},
				#2:{"v":{"x":-6,"y":-7},"%":0.35,},
				#3:{"v":{"x":-8,"y":-10},"%":0.5,},
				},
			"min_v":50,
			"i":images.icons.stats["rsp"],
			"t":"ROLL",
			"ct":"CROLL",
			"price":0.7,
			"step":1},
		"run_speed":{
			"postfix":"",
			"v":{
				0:{"v":{"x":1,"y":2},"%":0,},
				1:{"v":{"x":2,"y":4},"%":0.25,},
				2:{"v":{"x":5,"y":7},"%":0.45,},
				3:{"v":{"x":8,"y":10},"%":0.6,},
				},
			"-v":{
				0:{"v":{"x":-1,"y":-2},"%":0,},
				1:{"v":{"x":-2,"y":-3},"%":0.3,},
				2:{"v":{"x":-4,"y":-6},"%":0.45,},
				3:{"v":{"x":-7,"y":-9},"%":0.55,},
				},
			"min_v":50,
			"i":images.icons.stats["%sp"],
			"t":"SPEED",
			"ct":"CSPEED",
			"price":0.5,
			"step":1
			},
		"hp":{
			"postfix":"",
			"v":{
				0:{"v":{"x":0.3,"y":0.75},"%":0.1,},
				1:{"v":{"x":0.76,"y":1.35},"%":0.3,},
				2:{"v":{"x":1.36,"y":1.5},"%":0.4,},
				3:{"v":{"x":1.52,"y":1.7},"%":0.6,},
				},
			"-v":{
				0:{"v":{"x":-0.45,"y":-0.7},"%":0,},
				1:{"v":{"x":-0.71,"y":-1.2},"%":0.2,},
				2:{"v":{"x":-1.3,"y":-1.52},"%":0.35,},
				3:{"v":{"x":-1.53,"y":-1.72},"%":0.55,},
				},
			"min_v":1,
			"i":images.icons.stats.hp,
			"t":"HP",
			"ct":"CHP",
			"price":6.2,
			"step":0.01
			},
		"hp_regen":{
			"postfix":"",
			"v":{
				0:{"v":{"x":0.001,"y":0.003},"%":0.25,},
				1:{"v":{"x":0.003,"y":0.005},"%":0.45,},
				2:{"v":{"x":0.005,"y":0.009},"%":0.6,},
				3:{"v":{"x":0.01,"y":0.012},"%":0.75,},
				},
			"-v":{
				0:{"v":{"x":-0.001,"y":-0.002},"%":0,},
				1:{"v":{"x":-0.003,"y":-0.005},"%":0.25,},
				2:{"v":{"x":-0.006,"y":-0.009},"%":0.4,},
				3:{"v":{"x":-0.01,"y":-0.015},"%":0.6,},
				},
			"min_v":0,
			"i":images.icons.stats.hp_regen,
			"t":"HP_REGEN",
			"ct":"CHP_REGEN",
			"price":7.8,
			"step":0.001
			},
		"dmg":{
			"postfix":"",
			"v":{
				0:{"v":{"x":0.2,"y":1},"%":0.05,},
				#1:{"v":{"x":0.55,"y":0.9},"%":0.15,},
				#2:{"v":{"x":1.05,"y":1.24},"%":0.2,},
				#3:{"v":{"x":1.35,"y":1.5},"%":0.4,},
				},
			"-v":{
				0:{"v":{"x":-0.25,"y":-0.55},"%":0,},
				#1:{"v":{"x":-0.6,"y":-0.7},"%":0.16,},
				#2:{"v":{"x":-0.95,"y":-1.2},"%":0.28,},
				#3:{"v":{"x":-1.25,"y":-1.35},"%":0.35,},
				},
			"min_v":0,
			"i":images.icons.stats.dmg,
			"t":"DMG",
			"ct":"CDMG",
			"price":8.5,
			"step":0.01
			},
		"crit_dmg":{
			"postfix":"",
			"v":{
				0:{"v":{"x":0.2,"y":1.5},"%":0.15,},
				#1:{"v":{"x":0.44,"y":0.54},"%":0.35,},
				#2:{"v":{"x":0.6,"y":0.75},"%":0.48,},
				#3:{"v":{"x":1,"y":1.5},"%":0.62,},
				},
			"-v":{
				0:{"v":{"x":-0.3,"y":-1.3},"%":0.05,},
				#1:{"v":{"x":-0.56,"y":-0.7},"%":0.2,},
				#2:{"v":{"x":-0.744,"y":-0.9},"%":0.38,},
				#3:{"v":{"x":-0.95,"y":-1.3},"%":0.54,},
				},
			"min_v":0,
			"i":images.icons.stats["crit_dmg"],
			"t":"CRIT_DMG",
			"ct":"CCRIT_DMG",
			"price":7.5,
			"step":0.01
			},
		"%crit_dmg":{
			"postfix":"%",
			"v":{
				0:{"v":{"x":0.01,"y":0.03},"%":0.09,},
				1:{"v":{"x":0.04,"y":0.05},"%":0.28,},
				2:{"v":{"x":0.06,"y":0.07},"%":0.5,},
				3:{"v":{"x":0.08,"y":0.10},"%":0.68,},
				},
			"-v":{
				0:{"v":{"x":-0.01,"y":-0.02},"%":0.05,},
				1:{"v":{"x":-0.03,"y":-0.04},"%":0.25,},
				2:{"v":{"x":-0.05,"y":-0.06},"%":0.38,},
				3:{"v":{"x":-0.07,"y":-0.09},"%":0.5,},
				},
			"min_v":0,
			"i":images.icons.stats["%crit_dmg"],
			"t":"%CRIT_DMG",
			"ct":"C%CRIT_DMG",
			"price":8,
			"step":0.01
			},
		"def":{
			"postfix":"",
			"v":{
				0:{"v":{"x":0.1,"y":0.5},"%":0.3,},
				#1:{"v":{"x":0.65,"y":0.75},"%":0.45,},
				#2:{"v":{"x":0.8,"y":0.95},"%":0.57,},
				#3:{"v":{"x":1.1,"y":1.3},"%":0.64,},
				},
			"-v":{
				0:{"v":{"x":-0.2,"y":-0.5},"%":0.35,},
				#1:{"v":{"x":-0.85,"y":-1.2},"%":0.4,},
				#2:{"v":{"x":-0.35,"y":-0.8},"%":0.56,},
				#3:{"v":{"x":-0.1,"y":-0.25},"%":0.68,},
				},
			"min_v":1,
			"i":images.icons.stats.def,
			"t":"DEF",
			"ct":"CDEF",
			"price":9.5,
			"step":0.01
			},
		"max_stamina":{
			"postfix":"",
			"v":{
				0:{"v":{"x":0.5,"y":0.75},"%":0.02,},
				1:{"v":{"x":0.75,"y":1},"%":0.26,},
				2:{"v":{"x":1,"y":1.5},"%":0.38,},
				3:{"v":{"x":1.5,"y":2},"%":0.44,},
				},
			"-v":{
				0:{"v":{"x":-0.5,"y":-0.75},"%":0,},
				1:{"v":{"x":-0.75,"y":-1},"%":0.16,},
				2:{"v":{"x":-1,"y":-1.5},"%":0.28,},
				3:{"v":{"x":-1.55,"y":-2.1},"%":0.46,},
				},
			"min_v":0.5,
			"i":images.icons.stats.max_stamina,
			"t":"MAX_STAMINA_VALUE",
			"ct":"CMAX_STAMINA_VALUE",
			"price":5.5,
			"step":0.01
			},
		"regen_stamina_point":{
			"postfix":"",
			"v":{
				0:{"v":{"x":0.01,"y":0.05},"%":0.14,},
				1:{"v":{"x":0.05,"y":0.07},"%":0.22,},
				2:{"v":{"x":0.08,"y":0.1},"%":0.36,},
				3:{"v":{"x":0.15,"y":0.5},"%":0.55,},
				},
			"-v":{
				0:{"v":{"x":-0.046,"y":-0.065},"%":0.18,},
				1:{"v":{"x":-0.031,"y":-0.045},"%":0.35,},
				2:{"v":{"x":-0.015,"y":-0.03},"%":0.46,},
				3:{"v":{"x":-0.02,"y":-0.01},"%":0.58,},
				},
			"min_v":0.1,
			"i":images.icons.stats.regen_stamina_point,
			"t":"STAMINA_REGEN_VALUE",
			"ct":"CSTAMINA_REGEN_VALUE",
			"price":7.2,
			"step":0.01
			},
		"take_area":{
			"postfix":"",
			"v":{
				0:{"v":{"x":1,"y":1.5},"%":0.05,},
				1:{"v":{"x":1.5,"y":2},"%":0.15,},
				2:{"v":{"x":2,"y":3},"%":0.24,},
				3:{"v":{"x":3,"y":4},"%":0.38,},
				},
			"-v":{
				0:{"v":{"x":-1,"y":-1.5},"%":0.5,},
				1:{"v":{"x":-1.5,"y":-2},"%":0.35,},
				2:{"v":{"x":-2,"y":-3},"%":0.10,},
				3:{"v":{"x":-3,"y":-4},"%":0.05,},
				},
			"min_v":10,
			"i":images.icons.stats.take_area,
			"t":"COLLECTING",
			"ct":"CCOLLECTING",
			"price":2.6,
			"step":1
			}
		},
	"updates":{
		"agility":{
			"i":images.undef,
			"t":"AGILITY_TEXT",
			"lvls":[
				{
					"stats":{
						"regen_stamina_point":{"x":0.008,"y":0.01},
						"max_stamina":0.01,
						"run_speed":{"x":1,"y":3},
						},
					"unlock_from":0,"value":6
				},
				{
					"stats":{
						"regen_stamina_point":{"x":0.01,"y":0.025},
						"max_stamina":0.02,
						"run_speed":{"x":4,"y":6},
						},
					"unlock_from":0.5,"value":8
					},
				]
			},
		"agility_hp":{
			"i":images.undef,
			"t":"AGILITY-HP_TEXT",
			"lvls":[
				{
					"stats":{
						"hp_regen":{"x":0.02,"y":0.04},
						"hp":{"x":0.04,"y":0.06},
						"regen_stamina_point":{"x":0.01,"y":0.02},
						"max_stamina":0.01,
						"run_speed":{"x":1,"y":3},
						},
					"unlock_from":0,"value":6
				},
				{
					"stats":{
						"hp_regen":{"x":0.02,"y":0.4},
						"hp":{"x":0.01,"y":0.4},
						"regen_stamina_point":{"x":0.01,"y":0.03},
						"max_stamina":0.03,
						"run_speed":{"x":2,"y":5},
						},
					"unlock_from":0.5,"value":8
					},
				]
			},
		"agility_def":{
			"i":images.undef,
			"t":"AGILITY-DEF_TEXT",
			"lvls":[
				{
					"stats":{
						"def":{"x":0.01,"y":0.03},
						"regen_stamina_point":{"x":0.005,"y":0.02},
						"max_stamina":0.03,
						},
					"unlock_from":0,"value":6
				},
				{
					"stats":{
						"def":{"x":0.045,"y":0.07},
						"regen_stamina_point":{"x":0.01,"y":0.04},
						"max_stamina":0.03,
						"run_speed":{"x":3,"y":6},
						},
					"unlock_from":0.5,"value":8
					},
				]
			},
		"hp":{
			"i":images.undef,
			"t":"HP_TEXT",
			"lvls":[
				{
					"stats":{
						"hp_regen":{"x":0.005,"y":0.01},
						"hp":{"x":0.05,"y":1},
						},
					"unlock_from":0,"value":7
				},
				{
					"stats":{
						"hp_regen":{"x":0.01,"y":0.02},
						"hp":1.5,
						},
					"unlock_from":0.5,"value":9
					},
				]
			},
		"hp_agility":{
			"i":images.undef,
			"t":"AGILITY-HP_TEXT",
			"lvls":[
				{
					"stats":{
						"hp_regen":{"x":0.02,"y":0.05},
						"hp":{"x":0.03,"y":0.4},
						"regen_stamina_point":{"x":0.008,"y":0.01},
						"max_stamina":0.03,
						},
					"unlock_from":0,
					"value":6
				},
				{
					"stats":{
						"hp_regen":{"x":0.7,"y":1.75},
						"hp":{"x":0.6,"y":1.1},
						"regen_stamina_point":{"x":0.1,"y":0.8},
						"max_stamina":0.03,
						"run_speed":{"x":3,"y":8},
						},
					"unlock_from":0.5,"value":8
					},
				]
			},
		"def":{
			"i":images.undef,
			"t":"DEF_TEXT",
			"lvls":[
				{
					"stats":{
						"def":{"x":0.025,"y":0.09},
						"dmg":{"x":0.01,"y":0.1},
						},
					"unlock_from":0,"value":10
				},
				{
					"stats":{
						"def":{"x":0.09,"y":0.22},
						"dmg":{"x":0.1,"y":0.3},
						},
					"unlock_from":0.5,"value":14
					},
				]
			},
		"def_hp":{
			"i":images.undef,
			"t":"DEF-HP_TEXT",
			"lvls":[
				{
					"stats":{
						"hp_regen":{"x":0.005,"y":0.02},
						"hp":{"x":0.02,"y":0.05},
						"def":{"x":0.09,"y":0.12},
						},
					"unlock_from":0,"value":10
				},
				{
					"stats":{
						"hp_regen":{"x":0.02,"y":0.06},
						"hp":{"x":0.055,"y":01},
						"def":{"x":0.12,"y":0.225},
						"dmg":{"x":0.25,"y":0.5},
						},
					"unlock_from":0.5,"value":14
					},
				]
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
		#		1:{"stats":{"def":3,"hp":-1,"hp_regen":0.01},"rare":Vector2(0.2,0.4),"value":35},
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
	}
}

func save_file_data():
	for e in get_tree().get_nodes_in_group("SN"):
		_save_node(e.save_data())
	var save_game := FileAccess.open(save_path+"/"+fname+suffix, FileAccess.WRITE)
	#save_game.store_buffer(dict_to_buf(sn))
	#print(dict_to_buf(sn))
	save_game.store_line(JSON.stringify(sn,"",false))
	save_game.close()
func load_file_data():
	if (FileAccess.file_exists(save_path+"/"+fname+suffix)):
		var save_game := FileAccess.open(save_path+"/"+fname+suffix, FileAccess.READ)
		if save_game.get_length()!=0:
			sn=JSON.parse_string(save_game.get_line())
			#sn=save_game.get_buffer(save_game.get_length())
			for e in sn.keys():
				if get_node_or_null(e)!=null:
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

func set_dark(r:bool=true):
	var cl:CanvasLayer=get_tree().root.get_node_or_null("darkness_bg")
	if r and cl==null:
		cl=CanvasLayer.new()
		cl.layer=3
		cl.name="darkness_bg"
		cl.process_mode=Node.PROCESS_MODE_ALWAYS
		var cr=ColorRect.new()
		cr.name="darkness"
		cr.set_anchors_preset(Control.PRESET_FULL_RECT)
		cr.color=Color(0,0,0,0)
		cl.add_child(cr)
		get_tree().root.add_child(cl)
		var tween = get_tree().create_tween().bind_node(cr).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(cr, "color", Color(0,0,0,1), 2)
		tween.tween_callback((func():
			emit_signal("darked",r)))
		print(tween.is_running())
	elif cl!=null:
		var cr=cl.get_node("darkness")
		cr.color=Color(0,0,0,1)
		var tween = get_tree().create_tween().bind_node(cr).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(cr, "color", Color(0,0,0,0), 2)
		tween.tween_callback((func():
			emit_signal("darked",r)
			cl.queue_free()))
