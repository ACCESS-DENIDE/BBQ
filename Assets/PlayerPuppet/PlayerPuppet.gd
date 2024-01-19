extends CharacterBody2D

const r_team_anim=preload("res://Resourses/Animations/player.tres")
const b_team_anim=preload("res://Resourses/Animations/player2.tres")
const z_team_anim=preload("res://Resourses/Animations/zombie.tres")

@export var gun:Gun

@export var abil:Ability

@onready var puppet_anim:AnimatedSprite2D = $PuppetAnim

var base_speed:float=0.0
var speed:float =0.0

var net_id:int
var predict_vel:Vector2=Vector2(0, 0)

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

var is_shooting:bool
var last_shoot:int
var reload_started:int
var bulets_in_mag:int
var is_hold:bool=false
var is_reloading:bool=false
var last_hit:int=-1
var shield_recharge_cd:int

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


func SwitchTeam(new_team:int):
	my_team=new_team
	match new_team:
		1:
			$PuppetAnim.sprite_frames=b_team_anim
			pass
		2:
			$PuppetAnim.sprite_frames=r_team_anim
			pass

func InitGame(id_abil:int, team:int, un_id:int):
	net_id=un_id
	my_team=team
	
	match team:
		1:
			$PuppetAnim.sprite_frames=b_team_anim
			pass
		2:
			$PuppetAnim.sprite_frames=r_team_anim
			pass
	
	if(Networking.is_authority):
		ability_id=id_abil
		match id_abil:
			0:
				ability_cd=GameGlobalVar.teleport_base_reload
				pass
			1:
				ability_cd=GameGlobalVar.revive_base_reload
				pass
			2:
				ability_cd=GameGlobalVar.mine_base_reload
				pass
			3:
				ability_cd=GameGlobalVar.century_base_reload
				pass
			4:
				ability_cd=GameGlobalVar.shield_base_reload
				pass
			5:
				ability_cd=GameGlobalVar.invincibility_base_reload
				pass
		bulets_in_mag=gun.mag_size
		ability_cd_val=0
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
		items.clear()
		for i in range(0, 15):
			items.push_back(0)
		
		last_shoot=-1
		dict.clear()
		dict["Amount"]=items
		Networking.SyncUiState(net_id, 4, dict)
		dict.clear()
		dict["DisplayName"]=gun.display_name
		Networking.SyncUiState(net_id, 6, dict)
		dict.clear()
		
		Networking.SyncSpeed(net_id, base_speed, speed)
		
		shield_recharge_cd=GameGlobalVar.shield_recharge_cd
	is_initiated=true



func SyncFunc(new_pos:Vector2, vel:Vector2, delta:float, rot:float):
	if(!is_initiated):
		return
	if(Networking.is_authority):
		#TODO:insert anticheat here
		predict_vel=vel
		rotation=rot
		$StabelNode.rotation=-rotation
		position=new_pos+(predict_vel*base_speed*(PlayerData.pings[net_id]/1000))
		pass
	else:
		predict_vel=vel
		rotation=rot
		$StabelNode.rotation=-rotation
		position=new_pos+(predict_vel*base_speed*(PlayerData.pings[1]/1000))

func LoadSpeed(base_sn:float, cur_sn:float):
	speed=cur_sn
	base_speed=cur_sn

func _physics_process(_delta):
	if(!is_initiated):
		return
	predict_vel=predict_vel.normalized()
	
	if (predict_vel.x!=0):
		velocity.x = predict_vel.x
	else:
		velocity.x = move_toward(velocity.x, 0, base_speed)
	if (predict_vel.y!=0):
		velocity.y = predict_vel.y
	else:
		velocity.y = move_toward(velocity.y, 0, base_speed)
	move_and_slide()
	
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
	
	$StabelNode/Label.text=str(position)


func _process(delta):
	
	if(Networking.is_authority):
		hp-=poison_dmg*delta
		if(!is_shocked):
			if(Time.get_ticks_msec()-last_hit>shield_recharge_cd):
				shield+=(GameGlobalVar.shield_per_sec_regen*(1+items[5]))*delta
				if(shield>base_shield):
					shield=base_shield
		UpdateUI(0)
		UpdateUI(1)
	

func SetAnim(id:int):
	match id:
		0:
			puppet_anim.play("idle")
			pass
		1:
			puppet_anim.play("walk")
		2:
			puppet_anim.play("run")
			pass

func MakeAction(action_id:int):
	match action_id:
		1:
			BeginShoot()
		-1:
			StopShoot()
		2:
			Reload()
		3:
			DashSwitch(true)
		-3:
			DashSwitch(false)

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
			dict["Base"]=base_hp
			Networking.SyncUiState(net_id, 0, dict)
		1:
			dict["State"]=shield
			dict["Base"]=base_shield
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

func PoisonOut():
	poison_dmg=0

func StunOut():
	is_stunned=false

func ShockOut():
	is_shocked=false


func Death():
	pass
