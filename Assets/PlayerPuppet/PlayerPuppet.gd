extends CharacterBody2D

var r_team_anim=preload("res://Resourses/Animations/player.tres")
var b_team_anim=preload("res://Resourses/Animations/player2.tres")
var z_team_anim=preload("res://Resourses/Animations/zombie.tres")

var base_speed
var speed = 300.0

var net_id:int
var predict_vel:Vector2=Vector2(0, 0)

@onready var puppet_anim:AnimatedSprite2D = $PuppetAnim

var my_team:int

var is_dashed:bool=false
var is_dash_cd:bool=true

var hp:int
var base_hp:int
var shield:int
var base_shield:int
var items=[]
var ability_cd:int
var ability_cd_val:int
var gold:int

var ability_id:int

var is_speed_loaded:bool=false


func DashSwitch(flg:bool):
	if(flg):
		if(is_dash_cd):
			is_dashed=true
			is_dash_cd=false
			speed=speed*GameGlobalVar.dash_multplyer
			$DashDuration.start(GameGlobalVar.dash_duration*items[1])
	else:
		is_dashed=false
		speed=base_speed*float(1+float(items[0]*0.3))
		$DashDuration.stop()
		$DashCD.start(GameGlobalVar.dash_cd)


func SwitchTeam(new_team:int):
	my_team=new_team
	match new_team:
		1:
			$PuppetAnim.sprite_frames=b_team_anim
			pass
		2:
			$PuppetAnim.sprite_frames=r_team_anim
			pass

func InitGame(id_abil:int, team:int):
	
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
		items.clear()
		for i in range(0, 15):
			items.push_back(0)
		
		
		
		is_speed_loaded=true
		
		dict.clear()
		dict["Amount"]=items
		Networking.SyncUiState(net_id, 4, dict)
		
		Networking.SyncSpeed(net_id, base_speed, speed)


var last_legit_pos:Vector2
var prev_skipped:bool=false
var stored_delta:int=0
var stored_delta_am:int=0

func SyncFunc(new_pos:Vector2, vel:Vector2, delta:float, rot:float, syncid:int):
	if(!is_speed_loaded):
		return
	if(Networking.is_authority):
		var way:float=Vector2(new_pos.x-last_legit_pos.x, new_pos.y-last_legit_pos.y).length()
		print("Delta: "+str(delta)+" Stored delta: "+str(stored_delta))
		if(float(delta+stored_delta)/(stored_delta_am+1)<17):
			print("Less 17")
			if(prev_skipped):
				print("Added")
				stored_delta+=delta
				stored_delta_am+=1
			else:
				print("Stored")
				prev_skipped=true
				stored_delta=delta
				stored_delta_am=1
			predict_vel=vel
			rotation=rot
			position=new_pos+(predict_vel*base_speed*(PlayerData.pings[net_id]/1000))
		else:
			print("More 17")
			var len:float=Vector2(new_pos.x-last_legit_pos.x, new_pos.y-last_legit_pos.y).length()
			print("Old pos: "+str(last_legit_pos))
			print("New pos: "+str(new_pos))
			print("Len: "+str(len))
			print(len/((delta+stored_delta)/1000))
			if(len/((delta+stored_delta)/1000)>speed):
				Networking.Kick(net_id, "Sync Error, last record speed: "+ str(len/((delta+stored_delta)/1000)))
				last_legit_pos=new_pos
				predict_vel=vel
				rotation=rot
				position=new_pos+(predict_vel*base_speed*(PlayerData.pings[net_id]/1000))
			else:
				print("NO KICK")
				last_legit_pos=new_pos
				predict_vel=vel
				rotation=rot
				position=new_pos+(predict_vel*base_speed*(PlayerData.pings[net_id]/1000))
			prev_skipped=false
			stored_delta=0
			stored_delta_am=0
		
		
	else:
		predict_vel=vel
		rotation=rot
		position=new_pos+(predict_vel*base_speed*(PlayerData.pings[1]/1000))

func LoadSpeed(base_sn:float, cur_sn:float):
	speed=cur_sn
	base_speed=cur_sn
	is_speed_loaded=true

func _physics_process(_delta):
	if(!is_speed_loaded):
		return
	predict_vel=predict_vel.normalized()
	
	if (predict_vel.x!=0):
		velocity.x = predict_vel.x * base_speed
	else:
		velocity.x = move_toward(velocity.x, 0, base_speed)
	if (predict_vel.y!=0):
		velocity.y = predict_vel.y * base_speed
	else:
		velocity.y = move_toward(velocity.y, 0, base_speed)
	move_and_slide()


func SetAnim(id:int):
	match id:
		0:
			puppet_anim.play("idle")
			pass
		1:
			if(is_dashed):
				puppet_anim.play("run")
			else:
				puppet_anim.play("walk")
			pass


func DashCooldownTime():
	is_dash_cd=true
	pass # Replace with function body.

func DashDurationTime():
	DashSwitch(false)
	pass # Replace with function body.
