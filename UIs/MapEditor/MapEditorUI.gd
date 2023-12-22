extends Control

var my_par:Node

var sellector:ItemList

var mode_num=0

var is_master_ui=false

var gm_matrix=[]

var mem_prop_nodes:int=0

var mem_item_nodes:int=0

var gm_display_links=[]


func ConnectEditor(par:Node):
	my_par=par
	

func UiAccess():
	my_par.Disable()

func UiStopAccess():
	if(is_master_ui==false):
		my_par.Enable()


func _ready():
	
	for i in range(0, 10):
		gm_matrix.push_back(0)
	
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/CTF)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/BF)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/DM)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/TDM)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/CP)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/TAG)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/CK)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/BW)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/VIR)
	gm_display_links.push_back($SaverWindow/MainGrid/ModesGrid/RAID)
	
	var editor=preload("res://Scenes/MapEditor/MapEditor.tscn").instantiate()
	Gameplay.add_child(editor)
	my_par=editor
	sellector=$BlockSellector
	sellector.select(0)
	SelectPen()


func BlockSelectorSwitch(index:int):
	my_par.SetPaintBlock(index)
	if(index==10):
		$PropertyEditor.visible=true
	else:
		$PropertyEditor.visible=false
	pass # Replace with function body.

func SelectPen():
	ActivateAll()
	$DrawType/Pen.disabled=true
	my_par.SetDrawMode(0)
	pass

func SelectLine():
	ActivateAll()
	$DrawType/Line.disabled=true
	my_par.SetDrawMode(1)
	pass

func SelectSquere():
	ActivateAll()
	$DrawType/Squere.disabled=true
	my_par.SetDrawMode(2)
	pass

func SelectBox():
	ActivateAll()
	$DrawType/Box.disabled=true
	my_par.SetDrawMode(3)
	pass


func ActivateAll():
	$DrawType/Pen.disabled=false
	$DrawType/Line.disabled=false
	$DrawType/Squere.disabled=false
	$DrawType/Box.disabled=false


func SpawnerModeSwitch(tab:int):
	my_par.SetSpawnerMode(tab)
	
	var inf=$PropertyEditor/Info
	
	match tab:
		0:
			inf.text="Used to spawn players in different modes"
			pass
		1:
			inf.text="Used to spawn props in different modes"
			pass
		2:
			inf.text="Used to spawn items in different modes"
			pass
	pass # Replace with function body.




func OnSliderChange(value):
	var val:int=$PropertyEditor/Slider.value
	my_par.SetSpawnerData(val)
	
	$PropertyEditor/CratePerc.text="Crate: "+str(val)+"%"
	$PropertyEditor/BarrelPerc.text="Barrel: "+str(100-val)+"%"
	
	
	pass # Replace with function body.



func OnLeftBtnDown():
	mode_num-=1
	if(mode_num==-1):
		mode_num=3
	
	
	var mode_name=$PropertyEditor/GridContainer/ModeName
	match mode_num:
		0:
			mode_name.text="Player Spawner"
			pass
		1:
			mode_name.text="Prop Spawner"
			pass
		2:
			mode_name.text="Item Spawner"
			
			pass
		3:
			mode_name.text="Gameplay Spawner"
			
			pass
			
	
	
	my_par.SetSpawnerMode(mode_num)
	pass # Replace with function body.


func OnRightBtnDown():
	mode_num+=1
	if(mode_num==4):
		mode_num=0
	
	var mode_name=$PropertyEditor/GridContainer/ModeName
	match mode_num:
		0:
			mode_name.text="Player Spawner"
			pass
		1:
			mode_name.text="Prop Spawner"
			pass
		2:
			mode_name.text="Item Spawner"
			pass
		3:
			mode_name.text="Gameplay Spawner"
			
			pass
	my_par.SetSpawnerMode(mode_num)
	pass # Replace with function body.


func OnPaddleInput(event):
	UiAccess()
	pass # Replace with function body.


func OnExitBtnDown():
	UImanager.SwitchUI("MainMenu")
	pass # Replace with function body.


func OnFileBtnDown():
	is_master_ui=true
	UiAccess()
	$SaveLoad.visible=true
	pass # Replace with function body.

func OnCancelBtnDown():
	is_master_ui=false
	$SaveLoad.visible=false
	$SaverWindow.visible=false
	$LoaderWindow.visible=false

func _exit_tree():
	my_par.get_parent().remove_child(my_par)
	my_par.queue_free()


func OnSaveBtnDown():
	$SaveLoad.visible=false
	$SaverWindow.visible=true
	CalculateGMmatrix()
	
	for i in range(0, 10):
		gm_display_links[i].visible=gm_matrix[i]
	$SaverWindow/MainGrid/TecSettingsGrid/MinPropGrid/MinProp.max_value=mem_prop_nodes
	$SaverWindow/MainGrid/TecSettingsGrid/MaxPropGrid/MaxProp.max_value=mem_prop_nodes
	$SaverWindow/MainGrid/TecSettingsGrid/MinItemGrid/MinItem.max_value=mem_item_nodes
	$SaverWindow/MainGrid/TecSettingsGrid/MaxItemGrid/MaxItem.max_value=mem_item_nodes
	pass # Replace with function body.


func OnGuiInpt(event):
	if(Input.is_action_just_released("Primary")):
		if(!is_master_ui):
			UiStopAccess()
	pass # Replace with function body.




func OnBtnSave():
	var map_name:TextEdit=$SaverWindow/MainGrid/NameGrid/MapNameSourse
	var map_min_prop:SpinBox=$SaverWindow/MainGrid/TecSettingsGrid/MinPropGrid/MinProp
	var map_max_prop:SpinBox=$SaverWindow/MainGrid/TecSettingsGrid/MaxPropGrid/MaxProp
	var map_min_item:SpinBox=$SaverWindow/MainGrid/TecSettingsGrid/MinItemGrid/MinItem
	var map_max_item:SpinBox=$SaverWindow/MainGrid/TecSettingsGrid/MaxItemGrid/MaxItem
	if(map_name.text==""):
		OS.alert("Name not found.")
		return
	
	var full_map_data={}
	
	full_map_data["MinProp"]=map_min_prop.value
	full_map_data["MaxProp"]=map_max_prop.value
	full_map_data["MinItem"]=map_min_item.value
	full_map_data["MaxItem"]=map_max_item.value
	
	full_map_data["GmMatrix"]=gm_matrix
	
	full_map_data["SpawnerData"]=my_par.spawner_info
	
	full_map_data["Shift"]=my_par.start_point_global
	
	full_map_data["Map"]=my_par.StringifyMap()
	
	
	
	var Saver=FileAccess.open("Maps/"+map_name.text+".bbq", FileAccess.WRITE)
	Saver.store_string(JSON.stringify(full_map_data, "\t"))
	Saver.close()
	
	OnCancelBtnDown()


func CalculateGMmatrix():
	var base_cou:int=my_par.base_map_cou
	var spawners:Dictionary=my_par.spawner_info
	
	var spawner_p:int=0
	var spawner_i:int=0
	var spawner_g:int=0
	
	for i in range(0, 10):
		gm_matrix[i]=0
	
	mem_prop_nodes=0
	
	for i in spawners.keys():
		match spawners[i]["Mode"]:
			0:
				spawner_p+=1
				pass
			1:
				mem_prop_nodes+=1
				pass
			2:
				spawner_i+=1
				pass
			3:
				spawner_g+=1
				pass
	
	mem_item_nodes=spawner_i
	
	if(spawner_p>0):
		gm_matrix[2]=1
		gm_matrix[3]=1
		gm_matrix[5]=1
		if(base_cou>0):
			gm_matrix[8]=1
			gm_matrix[9]=1
	if(base_cou>1):
		gm_matrix[0]=1
		gm_matrix[6]=1
		gm_matrix[7]=1
		gm_matrix[1]=1
		if(spawner_g>0):
			gm_matrix[4]=1
		
	
	
	
	

var preloaded_levels=[]

func LoadOpenerDown():
	preloaded_levels.clear()
	$LoaderWindow/GridContainer/AvailibLevels.clear()
	$LoaderWindow.visible=true
	$SaveLoad.visible=false
	var direct:DirAccess=DirAccess.open("res://Maps")
	
	for i in direct.get_files():
		if(i.split(".")[1]=="bbq"):
			$LoaderWindow/GridContainer/AvailibLevels.add_item(i.split(".")[0])
			preloaded_levels.push_back(i)
	
	
	
	pass # Replace with function body.


func OnLoadBtnDown():
	my_par.ClearTilemap()
	var id:int=$LoaderWindow/GridContainer/AvailibLevels.get_selected_items()[0]
	
	var Loader=FileAccess.open("Maps/"+preloaded_levels[id], FileAccess.READ)
	
	var map_data=JSON.parse_string(Loader.get_as_text())
	
	var shift_coord:Vector2i=(str_to_var("Vector2i"+map_data["Shift"]))
	
	var spawner_data=map_data["SpawnerData"]
	
	var new_spawner_data={}
	
	for i in spawner_data.keys():
		var old_x:int
		var old_y:int
		old_x=int(i.split(":")[0])
		old_y=int(i.split(":")[1])
		new_spawner_data[str(old_x-shift_coord.x)+":"+str(old_y-shift_coord.y)]=spawner_data[i]
	
	my_par.spawner_info=new_spawner_data
	
	for i in map_data["Map"].keys():
		var string_data=map_data["Map"][i]
		my_par.LoadTile(Vector2i(int(i.split(":")[0]), int(i.split(":")[1])), Vector3i(str_to_var("Vector3i"+map_data["Map"][i])), int(i.split(":")[2]))
	
	Loader.close()
	OnCancelBtnDown()
	pass # Replace with function body.
