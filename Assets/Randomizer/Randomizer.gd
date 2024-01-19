extends StaticBody2D

@export var item_chanse:float
@export var gun_chance:float
@export var megagun_chance:float
@export var explode_chance:float
@export var roll_time:int

var sprite:AnimatedSprite2D
var anim_player:AnimationPlayer
var timer:Timer

var is_rolling:bool=false

func _ready():
	sprite=$AnimatedSprite2D
	anim_player=$AnimationPlayer
	timer=$RollTIme
	print(input_pickable)

func OnInput(viewport, event, shape_idx):
	StartRoll(self)
	pass # Replace with function body.


func StartRoll(starter:Node):
	if(is_rolling):
		return
	is_rolling=true
	sprite.play("Roll")
	anim_player.play("Transition In")
	timer.start(roll_time)
	pass

func SwitchAnnim(anim_name):
	if(anim_name=="Transition In"):
		anim_player.play("Roll")
	pass # Replace with function body.

func SelfDistruct():
	pass


func MMove():
	StartRoll(self)
	pass # Replace with function body.
