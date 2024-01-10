extends CharacterBody2D

class_name Player

var r_team_anim=preload("res://Resourses/Animations/player.tres")
var b_team_anim=preload("res://Resourses/Animations/player2.tres")
var z_team_anim=preload("res://Resourses/Animations/zombie.tres")

var base_speed
var speed = 300.0

var is_dashed:bool=false
var is_dash_cd:bool=true

var my_team:int

var net_id:int


@onready var player_anim = $PlayerAnim

@export var my_complex:Node2D

@export var camera_2d:Camera2D

var disabled=true

var is_dead=false

var ability_id:int

var hp:int
var base_hp:int
var shield:int
var base_shield:int
var items=[]
var ability_cd:int
var ability_cd_val:int
var gold:int

func DashSwitch(flg:bool):
	if(flg):
		if(is_dash_cd):
			is_dashed=true
			#print("Is dashed True")
			is_dash_cd=false
			speed=speed*GameGlobalVar.dash_multplyer
			
			$DashDuration.start(GameGlobalVar.dash_duration*(items[1]+1))
			if(Networking.is_authority):
				Networking.SyncSpeed(net_id, base_speed, speed)
	else:
		if(is_dashed):
			is_dashed=false
			#print("Is dashed False")
			speed=base_speed*float(1+float(items[0]*0.3))
			$DashDuration.stop()
			$DashCD.start(GameGlobalVar.dash_cd)
			if(Networking.is_authority):
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

func InitGame(id_abil:int, team:int):
	
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
		
		
		
		
		
		dict.clear()
		dict["Amount"]=items
		Networking.SyncUiState(net_id, 4, dict)
		
		Networking.SyncSpeed(net_id, base_speed, speed)
		

func SyncFunc(new_pos:Vector2, vel:Vector2, delta:float, rot:float):
	pass


func _process(delta):
	if(!visible):
		return
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
		print(str(is_dashed)+" "+str(net_id))
		if(is_dashed):
			player_anim.play("run")
			Networking.SwitchPlayerAnim("player#"+str(net_id), 2)
		else:
			player_anim.play("walk")
			Networking.SwitchPlayerAnim("player#"+str(net_id), 1)
	

var packet_count:int=0

func _physics_process(_delta):
	if(disabled):
		return
	
	
	var local_pos=get_global_mouse_position()-position
	
	if(local_pos.x>0):
		rotation=asin(local_pos.normalized().y)+(PI/2)
	else:
		rotation=asin(0-local_pos.normalized().y)+(PI/2)-PI
	
	if(Input.is_action_just_pressed("Secondary")):
		Networking.DashPlayer(true)
	if(Input.is_action_just_released("Secondary")):
		Networking.DashPlayer(false)
	
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
	
	
	my_complex.UpdatePos(position)
	Networking.SyncPosPlayer(name, position, velocity, rotation)
	my_complex.SetLitRot(rotation)
	$StabelNode.rotation=-rotation
	

var UI
func SetUI(ref:Node):
	get_viewport().add_child(ref)

func SetAnim(id:int):
	pass





func DashCooldownTime():
	is_dash_cd=true
	pass # Replace with function body.

func DashDurationTime():
	DashSwitch(false)
	pass # Replace with function body.
