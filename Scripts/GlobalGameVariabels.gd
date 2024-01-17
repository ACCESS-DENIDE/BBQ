extends Node

#LOADER
var loaded_maps={}
var gamemodes=["Capture the flag", "Boss fight", "Death match", "Team DM", "Control point", "Tags", "Confirm Kill", "Base wars", "Virus", "Raid (shadow maggots)"]
var powers=["Teleport", "Revive", "Mine", "Century", "Shield", "Invincibility"]
var teams=["Random", "Blue", "Red"]


#PLAYER
var player_base_speed=19000
var player_base_hp=100
var player_base_shield=50


#ABILITY
var teleport_base_reload=2
var revive_base_reload=5
var mine_base_reload=2
var century_base_reload=3
var shield_base_reload=4
var invincibility_base_reload=5

#DASH
var dash_multplyer=5
var dash_cd=5
var dash_duration=1


#ITEMS
var speed_increaser_percent:int=30
var added_dash_time_sec:int=5
var dash_cd_decrease_percent:int=10
var additional_hp_amount:int=10
var additional_shield_amount:int=30
var shield_per_sec_regen:int=5
var crit_chance_per_item:int=10
var poison_damage_sec:int=3
var crit_mult_adder:int=1
var stun_per_eagle_sec:int=3
var special_disabled_per_batt_sec=5
var ignore_chance_percent=15
var bulets_per_item:int=5
var fire_rate_decrease_percent:int=15
var reload_speed_decrease_percent:int=20
