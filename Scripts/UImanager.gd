extends Controls
var CL
func _ready():
	CL=CanvasLayer.new()
	add_child(CL)
	SwitchUI("MainMenu")


var main_menu=preload("res://UIs/MainMenu/MainMenuUI.tscn")
var settings=preload("res://UIs/Settings/SettingsUI.tscn")
var connection_grid=preload("res://UIs/ConnectionGrid/ConnectionGrid.tscn")
var in_game_ui=preload("res://UIs/InGame/InGameUI.tscn")
var lobby=preload("res://UIs/Lobby/LobbyUI.tscn")
var map_editor=preload("res://UIs/MapEditor/MapEditorUI.tscn")

func SwitchUI(ui_id:String):
	for i in CL.get_children():
		CL.remove_child(i)
		i.queue_free()
	var inst
	
	
	
	match ui_id:
		
		"MainMenu":
			inst=main_menu.instantiate()
			
			pass
		"Settings":
			inst=settings.instantiate()
			pass
		"ConnectionGrid":
			inst=connection_grid.instantiate()
			
			pass
		"Lobby":
			inst=lobby.instantiate()
			
			pass
		"InGame":
			inst=in_game_ui.instantiate()
			
			pass
		"MapEditor":
			inst=map_editor.instantiate()
			
			pass
	
	CL.add_child(inst)
	
	
