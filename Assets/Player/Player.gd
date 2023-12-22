extends CharacterBody2D

class_name Player

var base_speed
var speed = 300.0

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

func LoadSpeed(base_sn:float, cur_sn:float):
	speed=cur_sn
	base_speed=cur_sn


func InitGame(id_abil:int):
	ability_id=id_abil
	ability_cd_val=0
	match id_abil:
		0:
			UImanager.GetCurUI().SetAbilityName("Teleport")
			ability_cd=GameConstants.teleport_base_reload
			pass
		1:
			UImanager.GetCurUI().SetAbilityName("Revive")
			ability_cd=GameConstants.revive_base_reload
			pass
		2:
			UImanager.GetCurUI().SetAbilityName("Mine")
			ability_cd=GameConstants.mine_base_reload
			pass
		3:
			UImanager.GetCurUI().SetAbilityName("Century")
			ability_cd=GameConstants.century_base_reload
			pass
		4:
			UImanager.GetCurUI().SetAbilityName("Shield")
			ability_cd=GameConstants.shield_base_reload
			pass
		5:
			UImanager.GetCurUI().SetAbilityName("Invincibility")
			ability_cd=GameConstants.invincibility_base_reload
			pass
		
	
	if(Networking.is_authority):
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
	pass

func _physics_process(_delta):
	
	if(disabled):
		return
	
	var direction:Vector2=Vector2(0,0)
	if(!is_dead):
		
		direction.x = Input.get_axis("MoveLeft", "MoveRight")
		direction.y = Input.get_axis("MoveUp", "MoveDown")
		
	
	direction=direction.normalized()
	
	if (direction.x!=0):
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	if (direction.y!=0):
		velocity.y = direction.y * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	move_and_slide()
	
	my_complex.UpdatePos(position)
	
	var local_pos=get_global_mouse_position()-position
	
	if(direction.length()==0):
		Networking.SwitchPlayerAnim("player#"+str(net_id), 0)
		player_anim.play("idle")
		
	else:
		Networking.SwitchPlayerAnim("player#"+str(net_id), 1)
		player_anim.play("run")
	
	if(local_pos.x>0):
		rotation=asin(local_pos.normalized().y)+(PI/2)
	else:
		rotation=asin(0-local_pos.normalized().y)+(PI/2)-PI
	
	Networking.SyncPosPlayer(name, position, direction, rotation)
	my_complex.SetLitRot(rotation)
	
	if(Input.is_action_just_pressed("ZoomIn")):
		if(camera_2d.zoom.x<4):
			camera_2d.zoom+=Vector2(0.5, 0.5)
		
	
	if(Input.is_action_just_pressed("ZooomOut")):
		if(camera_2d.zoom.x>1):
			camera_2d.zoom-=Vector2(0.5, 0.5)
		
	

var UI
func SetUI(ref:Node):
	get_viewport().add_child(ref)

func SetAnim(id:int):
	pass
