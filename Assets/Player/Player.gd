extends CharacterBody2D


var SPEED = 300.0

var net_id:int

@onready var player_anim = $PlayerAnim

@onready var camera_2d:Camera2D = $Camera2D
@export var my_complex:Node2D

var disabled=true

func _physics_process(_delta):
	
	if(disabled):
		return
	
	var direction:Vector2=Vector2(0,0)
	
	
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	
	direction=direction.normalized()
	
	if (direction.x!=0):
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if (direction.y!=0):
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
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
