extends Resource

class_name Gun

@export var display_name:String
@export var damage:int
@export var spread:float
@export var mag_size:int
@export var anim_id:float
@export var texture:Texture2D
@export var texture_ofset:Vector2
@export var reload_time:float
@export var fire_rate:float
@export var max_dist:int
@export var bulets_per_shot:int
@export var is_automatic:bool
@export var is_pierce:bool

func Shoot(pos:Vector2, rot:float, items:Array, space2d:PhysicsDirectSpaceState2D, shooter:Node):
	var thread_arr=[]
	
	for i in range(0, bulets_per_shot):
		var new_th=Thread.new()
		new_th.start(Pew.bind(pos, rot, items, space2d, shooter))
		thread_arr.push_back(new_th)
	
	var cou:int=0
	
	while (thread_arr.size()>cou):
		if(!thread_arr[cou].is_alive()):
			thread_arr[cou].wait_to_finish()
			cou+=1
			
	thread_arr.clear()
	pass

func Pew(pos:Vector2, rot:float, items:Array, space2d:PhysicsDirectSpaceState2D, shooter:Node):
	
	var end_pos:Vector2
	var rng=RandomNumberGenerator.new()
	
	var rad_spread=spread*(PI/180)
	
	rot+=rng.randf_range(-rad_spread/2, rad_spread/2)
	
	end_pos.x=pos.x+sin(rot)*max_dist
	end_pos.y=pos.y+(0-cos(rot))*max_dist
	Gameplay.DebugLine(pos, end_pos)
	
	var query = PhysicsRayQueryParameters2D.create(pos, end_pos, 0xFFFFFFFF, GamemodeProcessor.GetAlly(shooter))
	var result = space2d.intersect_ray(query)
	var modifiers=[]
	
	modifiers.push_back(GameGlobalVar.poison_damage_sec*items[7])
	modifiers.push_back(GameGlobalVar.stun_per_eagle_sec*items[9])
	modifiers.push_back(GameGlobalVar.special_disabled_per_batt_sec*items[10])
	
	if(result.size()==0):
		#rng.free()
		return
	
	
	if(result.collider.has_method("Damage")):
		result.collider.Damage(damage, modifiers, is_pierce)
	#rng.free()
	pass
