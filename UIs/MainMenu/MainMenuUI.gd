extends Control


func _ready():
	var dir:DirAccess=DirAccess.open("res://")
	if(!dir.dir_exists("res://Maps")):
		dir.make_dir("Maps")


func OnPlayButtonDown():
	UImanager.SwitchUI("ConnectionGrid")


func OnSettingsButtonDown():
	pass # Replace with function body.


func OnExitButtonDown():
	get_tree().quit()
	pass # Replace with function body.


func OnEditorButtonDown():
	UImanager.SwitchUI("MapEditor")
	pass # Replace with function body.
