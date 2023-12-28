extends Node


var loaded_maps={}
var gamemodes=["Capture the flag", "Boss fight", "Death match", "Team DM", "Control point", "Tags", "Confirm Kill", "Base wars", "Virus", "Raid (shadow maggots)"]
var powers=["Teleport", "Revive", "Mine", "Century", "Shield", "Invincibility"]
var teams=["Random", "Blue", "Red"]

var player_base_speed=300
var player_base_hp=100
var player_base_shield=50

var teleport_base_reload=2
var revive_base_reload=5
var mine_base_reload=2
var century_base_reload=3
var shield_base_reload=4
var invincibility_base_reload=5

var dash_multplyer=2
var dash_cd=5
var dash_duration=1
