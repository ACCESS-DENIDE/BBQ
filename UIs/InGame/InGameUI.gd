extends Control


#UPDATE IDs
#0-HP
#1-Shield
#2-Gold
#3-Ability
#4-Items
#5-GunUI


var sb:SubViewport

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func SetAbilityName(a_name:String):
	$Ability/Ability_name.text=a_name+":"

func UpdateInfo(ui_id:int, val:Dictionary):
	match ui_id:
		0:
			$PlayerInfo/HPBar.max_value=val["Base"]
			$PlayerInfo/HPBar.value=val["State"]
			pass
		1:
			$PlayerInfo/ShieldBar.max_value=val["Base"]
			$PlayerInfo/ShieldBar.value=val["State"]
			pass
		2:
			$PlayerInfo/GoldAm.text=str(val["State"])+" $"
			pass
		3:
			$Ability/AbilityRechargeProgress.max_value=val["Base"]
			$Ability/AbilityRechargeProgress.value=val["State"]
			pass
		4:
			pass
		
	pass
