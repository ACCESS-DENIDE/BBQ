extends CharacterBody2D

class_name Player

const  r_team_anim=preload("res://Resourses/Animations/player.tres")
const b_team_anim=preload("res://Resourses/Animations/player2.tres")
const z_team_anim=preload("res://Resourses/Animations/zombie.tres")

@export var gun:Gun

@export var abil:Ability

@onready var player_anim = $PlayerAnim
@onready var camera_2d = $Camera2D

var base_speed:float =0.0
var speed:float = 0.0

var net_id:int

var my_team:int
var ability_id:int

var is_dashed:bool=false
var is_dash_cd:bool=true

var is_invincible:bool=false
var is_stunned:bool=false
var is_shocked:bool=false
var poison_dmg:int=0

var is_dead:bool=false

var is_initiated:bool=false

var hp:float
var base_hp:int
var shield:float
var base_shield:int
var items=[]
var ability_cd:int
var ability_cd_val:int
var gold:int
var shield_recharge_cd:int

var is_shooting:bool
var last_shoot:int
var reload_started:int
var bulets_in_mag:int
var is_hold:bool=false
var is_reloading:bool=false
var last_hit:int=-1

func DashSwitch(flg:bool):
	if(flg):
		if(is_dash_cd && !is_stunned):
			is_dashed=true
			is_dash_cd=false
			speed=speed*GameGlobalVar.dash_multplyer
			
			$DashDuration.start(GameGlobalVar.dash_duration+(items[1]*GameGlobalVar.added_dash_time_sec))
			if(Networking.is_authority):
				Networking.SyncSpeed(net_id, base_speed, speed)
	else:
		if(is_dashed):
			is_dashed=false
			speed=base_speed*float(1+float(items[0]*(GameGlobalVar.speed_increaser_percent/100)))
			$DashDuration.stop()
			$DashCD.start(GameGlobalVar.dash_cd*float(Math.HardPercent(GameGlobalVar.dash_cd_decrease_percent, items[2])))
			if(Networking.is_authority):
				Networking.SyncSpeed(net_id, base_speed, speed)
	Networking.SyncSpeed(net_id, base_speed, speed)

func LoadSpeed(base_sn:float, cur_sn:float):
	speed=cur_sn
	base_speed=cur_sn
	

func SwitchTeam(new_team:int):
	my_team=new_team
	
	match new_team:
		1:
			$PlayerAnim.sprite_frames=b_team_anim
			pass
		2:
			$PlayerAnim.sprite_frames=r_team_anim
			pass

func InitGame(id_abil:int, team:int, un_id:int):
	net_id=un_id
	my_team=team
	
	match team:
		1:
			$PlayerAnim.sprite_frames=b_team_anim
			pass
		2:
			$PlayerAnim.sprite_frames=r_team_anim
			pass
	
	ability_id=id_abil
	ability_cd_val=0
	match id_abil:
		0:
			UImanager.GetCurUI().SetAbilityName("Teleport")
			ability_cd=GameGlobalVar.teleport_base_reload
			pass
		1:
			UImanager.GetCurUI().SetAbilityName("Revive")
			ability_cd=GameGlobalVar.revive_base_reload
			pass
		2:
			UImanager.GetCurUI().SetAbilityName("Mine")
			ability_cd=GameGlobalVar.mine_base_reload
			pass
		3:
			UImanager.GetCurUI().SetAbilityName("Century")
			ability_cd=GameGlobalVar.century_base_reload
			pass
		4:
			UImanager.GetCurUI().SetAbilityName("Shield")
			ability_cd=GameGlobalVar.shield_base_reload
			pass
		5:
			UImanager.GetCurUI().SetAbilityName("Invincibility")
			ability_cd=GameGlobalVar.invincibility_base_reload
			pass
		
	
	if(Networking.is_authority):
		bulets_in_mag=gun.mag_size
		
		var dict={}
		gold=0
		base_speed=GameGlobalVar.player_base_speed
		base_hp=GameGlobalVar.player_base_hp
		base_shield=GameGlobalVar.player_base_shield
		hp=base_hp
		shield=base_shield
		speed=base_speed
		dict["State"]=hp
		dict["Base"]=base_hp
		Networking.SyncUiState(net_id, 0, dict)
		dict["State"]=shield
		dict["Base"]=base_shield
		Networking.SyncUiState(net_id, 1, dict)
		dict["State"]=gold
		dict["Base"]=0
		Networking.SyncUiState(net_id, 2, dict)
		dict["State"]=ability_cd_val
		dict["Base"]=ability_cd
		Networking.SyncUiState(net_id, 3, dict)
		dict["State"]=bulets_in_mag
		dict["Base"]=gun.mag_size
		Networking.SyncUiState(net_id, 5, dict)
		last_shoot=-1
		items.clear()
		for i in range(0, 15):
			items.push_back(0)
		
		
		
		
		
		dict.clear()
		dict["Amount"]=items
		Networking.SyncUiState(net_id, 4, dict)
		dict.clear()
		dict["DisplayName"]=gun.display_name
		Networking.SyncUiState(net_id, 6, dict)
		dict.clear()
		
		Networking.SyncSpeed(net_id, base_speed, speed)
		shield_recharge_cd=GameGlobalVar.shield_recharge_cd
		Respawn()
	is_initiated=true

func SyncFunc(new_pos:Vector2, vel:Vector2, delta:float, rot:float):
	pass


func _process(delta):
	if(!is_initiated):
		return
	
	
	if(Networking.is_authority && Gameplay.is_started):
		hp-=poison_dmg*delta
		if(!is_shocked):
			if(Time.get_ticks_msec()-last_hit>shield_recharge_cd):
				shield+=(GameGlobalVar.shield_per_sec_regen*(1+items[5]))*delta
				if(shield>base_shield+GameGlobalVar.additional_shield_amount*items[4]):
					shield=base_shield
		UpdateUI(0)
		UpdateUI(1)
	
	if(Input.is_action_just_pressed("ZoomIn")):
		if(camera_2d.zoom.x<4):
			camera_2d.zoom+=Vector2(0.5, 0.5)
		
	
	if(Input.is_action_just_pressed("ZooomOut")):
		if(camera_2d.zoom.x>1):
			camera_2d.zoom-=Vector2(0.5, 0.5)
	
	var direction:Vector2=velocity
	
	if(direction.length()==0):
		Networking.SwitchPlayerAnim("player#"+str(net_id), 0)
		player_anim.play("idle")
		
	else:
		if(is_dashed):
			player_anim.play("run")
			Networking.SwitchPlayerAnim("player#"+str(net_id), 2)
		else:
			player_anim.play("walk")
			Networking.SwitchPlayerAnim("player#"+str(net_id), 1)
	

var packet_count:int=0

func _physics_process(_delta):
	if(!is_initiated):
		return
	
	if(is_shooting):
		if(bulets_in_mag==0):
			Reload()
		if(is_hold):
			if(gun.is_automatic):
				if((Time.get_ticks_msec()-last_shoot>gun.fire_rate*1000 || last_shoot==-1) && bulets_in_mag>0):
					bulets_in_mag-=1
					gun.Shoot(position, rotation, items, get_world_2d().direct_space_state, self)
					UpdateUI(5)
					last_shoot=Time.get_ticks_msec()
		else:
			if((Time.get_ticks_msec()-last_shoot>gun.fire_rate*1000|| last_shoot==-1) && bulets_in_mag>0):
				bulets_in_mag-=1
				gun.Shoot(position, rotation, items, get_world_2d().direct_space_state, self)
				is_hold=true
				UpdateUI(5)
				last_shoot=Time.get_ticks_msec()
	
	var local_pos=get_global_mouse_position()-position
	
	if(local_pos.x>0):
		rotation=asin(local_pos.normalized().y)+(PI/2)
	else:
		rotation=asin(0-local_pos.normalized().y)+(PI/2)-PI
	
	if(Input.is_action_just_pressed("Secondary")):
		if(Networking.is_authority):
			DashSwitch(true)
		else:
			Networking.RequestAction(3)
	if(Input.is_action_just_released("Secondary")):
		if(Networking.is_authority):
			DashSwitch(false)
		else:
			Networking.RequestAction(-3)
	
	var direction:Vector2=Vector2(0,0)
	if(!is_dead):
		
		direction.x = Input.get_axis("MoveLeft", "MoveRight")
		direction.y = Input.get_axis("MoveUp", "MoveDown")
		
	
	direction=direction.normalized()
	
	if (direction.x!=0):
		velocity.x = direction.x * speed*_delta
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	if (direction.y!=0):
		velocity.y = direction.y * speed*_delta
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	move_and_slide()
	
	
	$StabelNode/Label.text=str(position)
	
	
	Networking.SyncPosPlayer(name, position, velocity, rotation)
	$StabelNode.rotation=-rotation
	

var UI
func SetUI(ref:Node):
	get_viewport().add_child(ref)

func SetAnim(id:int):
	pass

func _input(event):
	if(!is_initiated):
		return
	if(event.is_action_pressed("Primary")):
		if(Networking.is_authority):
			BeginShoot()
		else:
			Networking.RequestAction(1)
	if(event.is_action_released("Primary")):
		if(Networking.is_authority):
			StopShoot()
		else:
			Networking.RequestAction(-1)
	if(event.is_action_released("Reload")):
		if(Networking.is_authority):
			Reload()
		else:
			Networking.RequestAction(2)

func Reload():
	if(!is_reloading):
		is_reloading=true
		bulets_in_mag=0
		UpdateUI(5)
		$ReloadTimer.start(gun.reload_time*Math.HardPercent(GameGlobalVar.reload_speed_decrease_percent, items[14]))

func BeginShoot():
	is_shooting=true

func StopShoot():
	is_shooting=false
	is_hold=false

func DashCooldownTime():
	is_dash_cd=true
	pass # Replace with function body.

func DashDurationTime():
	DashSwitch(false)
	pass # Replace with function body.


func ReloadTimerOut():
	is_reloading=false
	bulets_in_mag=gun.mag_size+items[12]*GameGlobalVar.bulets_per_item
	UpdateUI(5)

func UpdateUI(update_id:int):
	var dict={}
	match update_id:
		0:
			dict["State"]=hp
			dict["Base"]=base_hp+GameGlobalVar.additional_hp_amount*items[3]
			Networking.SyncUiState(net_id, 0, dict)
		1:
			dict["State"]=shield
			dict["Base"]=base_shield+GameGlobalVar.additional_shield_amount*items[4]
			Networking.SyncUiState(net_id, 1, dict)
		2:
			dict["State"]=gold
			dict["Base"]=0
			Networking.SyncUiState(net_id, 2, dict)
		3:
			dict["State"]=ability_cd_val
			dict["Base"]=ability_cd
			Networking.SyncUiState(net_id, 3, dict)
		4:
			dict.clear()
			dict["Amount"]=items
			Networking.SyncUiState(net_id, 4, dict)
		5:
			dict["State"]=bulets_in_mag
			dict["Base"]=gun.mag_size
			Networking.SyncUiState(net_id, 5, dict)
		6:
			dict["DisplayName"]=gun.display_name
			Networking.SyncUiState(net_id, 6, dict)
			dict.clear()
		-1:
			dict["State"]=hp
			dict["Base"]=base_hp+GameGlobalVar.additional_hp_amount*items[3]
			Networking.SyncUiState(net_id, 0, dict)
			dict["State"]=shield
			dict["Base"]=base_shield+GameGlobalVar.additional_shield_amount*items[4]
			Networking.SyncUiState(net_id, 1, dict)
			dict["State"]=gold
			dict["Base"]=0
			Networking.SyncUiState(net_id, 2, dict)
			dict["State"]=ability_cd_val
			dict["Base"]=ability_cd
			Networking.SyncUiState(net_id, 3, dict)
			dict["State"]=bulets_in_mag
			dict["Base"]=gun.mag_size
			Networking.SyncUiState(net_id, 5, dict)
			dict.clear()
			dict["Amount"]=items
			Networking.SyncUiState(net_id, 4, dict)
			dict.clear()
			dict["DisplayName"]=gun.display_name
			Networking.SyncUiState(net_id, 6, dict)
			dict.clear()


func Damage(damage:int, modifiers:Array, is_pierce:bool):
	if(is_invincible):
		return
	var rng=RandomNumberGenerator.new()
	if(rng.randf()>(pow(1-(float(GameGlobalVar.ignore_chance_percent)/100), items[11]))):
		#rng.free()
		return
	#rng.free()
	if(shield>0):
		if(is_pierce):
			var remnant_damage=damage-shield
			if(remnant_damage>=0):
				shield=0
				hp=hp-remnant_damage
			else:
				shield=shield-damage
		else:
			shield=shield-damage
			if(shield<0):
				shield=0
	else:
		hp=hp-damage
		if(hp<=0):
			Death()
	
	if(modifiers[0]>0):
		poison_dmg=damage/10
		$PoisonDmg.start(modifiers[0])
	
	if(modifiers[1]>0):
		is_stunned=true
		$StunTimer.start(modifiers[1])
	
	if(modifiers[2]>0):
		is_shocked=true
		$OffTimer.start(modifiers[2])
	last_hit=Time.get_ticks_msec()
	UpdateUI(0)
	UpdateUI(1)
	
	pass

func Teleport(pos:Vector2):
	if(!Networking.is_authority):
		return
	
	position=pos
	Networking.SyncPosPlayer(name, position, velocity, rotation)

func PoisonOut():
	poison_dmg=0

func StunOut():
	is_stunned=false

func ShockOut():
	is_shocked=false

func Respawn():
	is_dead=false
	hp=base_hp+GameGlobalVar.additional_hp_amount*items[3]
	shield=base_shield+GameGlobalVar.additional_shield_amount*items[4]
	ReloadTimerOut()
	collision_layer=1
	visible=true
	Teleport(GamemodeProcessor.GetRespawnLock(self))
	UpdateUI(-1)

func Death():
	is_dead=true
	collision_layer=0
	visible=false
	$RespawnTimer.start(GameGlobalVar.respawn_time)
	pass
