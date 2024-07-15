extends RigidBody2D
@export_group("parametrs")
@export var dif:float=0
@export var elite:bool=false
@export var run_speed:float=25.0
@export var stop_range_from:float=0
@export var stop_range_to:float=0
@export var statuses:Dictionary={
	"d":"death",
	"i":"idle",
	"r":"run",
	}
@export var doing_chance_list={}
@export_group("defance")
@export_range(1,99999) var def_from:float=1
@export_range(1,99999) var def_to:float=1
@export_group("life")
@export_range(1,99999) var hp_from:float=1
@export_range(1,99999) var hp_to:float=1

var target
@onready var hb=$hurt_box
@onready var na=$na
@onready var sp=get_node_or_null("visual/sp")
@onready var ap=get_node_or_null("visual/ap")
@onready var see=$see
var doings_times=[]
var cur_target_pos=Vector2.ZERO
var attacks_timer:float=0
var think_timer:float=0
var think_time:float=1
var state="i"
@onready var cur_anim=statuses[state]
func eye_contact_with(obj):
	return see.get_collider()==obj
func get_sqrt(obj):
	return fnc._sqrt(obj.global_position-global_position)
var last_anim:int=0
func set_anim(anim_name:String,to_target:Vector2=na.get_next_path_position(),oneshoot:bool=false,changeing_pos:bool=true):
	if anim_name!="" and fnc._sqrt(to_target-global_position)>1 and sp!=null and ap!=null:
		var tname=""
		var anim=get_ang_move(rad_to_deg((to_target-global_position).angle())+180,90)*int(changeing_pos)+last_anim*int(!changeing_pos)
		last_anim=anim
		if anim==0:
			tname="_right"
		elif anim==2:
			tname="_left"
		elif anim==1:
			tname="_down"
		elif anim==3:
			tname="_up"
		if oneshoot:
			if sp.animation!=anim_name+tname:
				sp.animation=anim_name+tname
				ap.play(anim_name)
				anim_finish=false
				cur_anim=anim_name
		else:
			if sp.get_sprite_frames().get_animation_names().has(anim_name+tname):
				sp.animation=anim_name+tname
			ap.play(anim_name)
			cur_anim=anim_name
			anim_finish=false
func get_ang_move(angle:float,ex:float):
	var ang1=abs(ex)
	var le=int(360/ang1)
	var ang=int(abs(angle)+180+ang1/2)%360
	if ang>=0:for e in range(0,le):
		if ang>=e*ang1 and ang<(e+1)*ang1:
			return e
var anim_finish:bool=false
func pre_ready():pass
func past_ready():pass
func pre_status():pass
func post_status():pass
func new_dos(_delta:float):pass
func _on_die():pass
func _ready():
	pre_ready()
	if sp!=null and sp.material!=null:
		sp.material.set_deferred("shader_parameter/line_thickness",1.2*int(elite))
	var def=0
	if def_from!=def_to:
		def=fnc._with_dific(randf_range(def_from,def_to),dif)
	else:
		def=def_from
	hb.s_m_d(def+def*1.5*int(elite))
	hb.set_def(def+def*1.5*int(elite))
	var hp=0
	if hp_from!=hp_to:
		hp=fnc._with_dific(randf_range(hp_from,hp_to),dif)
	else:
		hp=hp_from
	hb.s_m_h(hp+hp*1.5*int(elite))
	hb.set_he(hp+hp*1.5*int(elite))
	na.max_speed=run_speed
	if ap!=null:
		ap.connect("animation_finished",Callable(self,"_on_ap_animation_finished"))
	for e in doing_chance_list.keys():
		doings_times.append(doing_chance_list[e])
	past_ready()
var current_action:String=""
func thinker():
	if think_timer>=think_time and current_action=="":
		think_timer=0
		current_action=doing_chance_list.keys()[fnc._with_chance_ulti(doings_times)]
func _process(_delta):
	queue_redraw()
func _integrate_forces(st):
	#see.rotation_degrees=fnc.angle(target.global_position-global_position)

	see.target_position=target.global_position-global_position
	if target.state!="d":
		if state!="wait_anim" and state!="d":
			if eye_contact_with(target) and get_sqrt(target)<stop_range_to:
				cur_target_pos=target.global_position
				if to_idle() and state!="wait_anim" :
					state="i"
			if (get_sqrt(target)>=stop_range_to ) and to_idle():
				cur_target_pos=target.global_position
				state="r"
			if get_sqrt(target)<stop_range_from and eye_contact_with(target) and to_idle():
				cur_target_pos=global_position+(global_position-target.global_position).normalized()*stop_range_from
				state="r"
			in_status_think()
			na.target_position=cur_target_pos
	else:
		state="i"
	pre_status()
	find_status(st.get_step())
	post_status()
func timers(_delta):
	attacks_timer+=_delta
	think_timer+=_delta
func in_status_think():pass
func to_idle():return true
func find_status(_delta:float):
	if state=="wait_anim":
		if anim_finish:
			state="i"
			current_action=""
	if state=="r":
		set_anim(statuses[state])
		timers(_delta)
		thinker()
		na.max_speed=run_speed
		var cvec=global_position.direction_to(na.get_next_path_position())*run_speed
		na.set_velocity(cvec)
		if na.is_navigation_finished() and (get_sqrt(target)<=stop_range_to):
			state="i"
			return
	if state=="i":
		na.max_speed=run_speed
		if !eye_contact_with(target):
			set_anim(statuses[state])
		else:
			set_anim(statuses[state],target.global_position)
		na.set_velocity(Vector2.ZERO)
		timers(_delta)
		thinker()
	if state=="d":
		na.max_speed=run_speed
		set_anim(statuses[state])
		na.set_velocity(Vector2.ZERO)
	new_dos(_delta)
func move(safe_velocity):set_linear_velocity(safe_velocity)
func _on_ap_animation_finished(anim_name):anim_finish=true
func delete():
	set_linear_velocity(Vector2.ZERO)
	_on_die()
	state="d"
