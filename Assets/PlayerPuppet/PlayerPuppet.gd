extends CharacterBody2D

var base_speed
var speed = 300.0

var net_id:int
var predict_vel:Vector2=Vector2(0, 0)

@onready var puppet_anim:AnimatedSprite2D = $PuppetAnim

var is_data_synced=false

var hp:int
var base_hp:int
var shield:int
var base_shield:int
var items=[]
var ability_cd:int
var ability_cd_val:int
var gold:int

var ability_id:int

func InitGame(id_abil:int):
	ability_id=id_abil
	ability_cd_val=0
	if(Networking.is_authority):
		ability_id=id_abil
		ability_cd_val
		var dict={}
		gold=0
		base_speed=GameConstants.player_base_speed
		base_hp=GameConstants.player_base_hp
		base_shield=GameConstants.player_base_shield
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
		
		
		
		
		
		dict.clear()
		dict["Amount"]=items
		Networking.SyncUiState(net_id, 4, dict)
		
		Networking.SyncSpeed(net_id, base_speed, speed)
		



func SyncFunc(new_pos:Vector2, vel:Vector2, delta:float, rot:float):
	if(!is_data_synced):
		return
	if(Networking.is_authority):
		delta=delta+PlayerData.pings[net_id]
		var pos_delt:Vector2=(new_pos-position)
		var vec_len=sqrt(pow(pos_delt.x, 2)+pow(pos_delt.y, 2))
		if(((vec_len)*(1/(delta/1000)))>base_speed+1):
			Networking.Kick(net_id, "Sync error")
		else:
			predict_vel=vel
			position=new_pos+(predict_vel*base_speed*(PlayerData.pings[net_id]/1000))
			rotation=rot
			Networking.SyncPosPlayer(name, position, predict_vel, rot)
	else:
		predict_vel=vel
		rotation=rot
		position=new_pos+(predict_vel*base_speed*(PlayerData.pings[1]/1000))

func LoadSpeed(base_sn:float, cur_sn:float):
	speed=cur_sn
	base_speed=cur_sn
	is_data_synced=true

func _physics_process(_delta):
	if(!is_data_synced):
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
			puppet_anim.play("run")
			pass
