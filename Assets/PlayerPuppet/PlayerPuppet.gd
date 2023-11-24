extends CharacterBody2D

var base_speed=300
var net_id:int
var predict_vel:Vector2=Vector2(0, 0)

@onready var puppet_anim:AnimatedSprite2D = $PuppetAnim


func SyncFunc(new_pos:Vector2, vel:Vector2, delta:float, rot:float):
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



func _physics_process(_delta):
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
