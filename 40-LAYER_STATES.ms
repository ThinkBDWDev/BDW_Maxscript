/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose: Saving and loading layer states
:History:V2 

:Todo: add notification of new layers added to scene files.. 
:Bugs: List update --fixed
:Tests: 
*******************************************************HeaderEnd*/




Global INIFilePath = undefined
Global INIFileCats = #()
Global CatName = undefined
Global IniFilePath = (getdir #Scene + "/" + "TempLayers.ini")

--Layers
Global LayerState =#()
Item =#()

fn ReadWriteIniToRoot StringContent:"" FilePath: Write: =
(

	
	
	if Write == true then
	(
		
	RootNodeID = (getAppData rootNode -1000200)
	
	if RootNodeID == undefined do
	(
		setAppData rootNode -1000200 StringContent
	)	
		
	
	getTxt = getAppData rootNode -1000200
	File = FilePath
	txt = getTxt
	f = (createFile File)
	format txt to:f
	close f
		
	txt = ((dotnetClass "System.IO.File").ReadAllText FilePath as string)
	setAppData rootNode -1000200 ""
	setAppData rootNode -1000200 txt
	)
	else
	(
	try(
	txt = ((dotnetClass "System.IO.File").ReadAllText FilePath as string)
	setAppData rootNode -1000200 txt)catch()
	)

)

fn RecordLayerState arrOff: record:true =
(
	
if record == true then 
(
 
for x=0 to LayerManager.count-1 do 
(

	if (LayerManager.getLayer x).on ==false then
	(
		try
		(
		layerName = (LayerManager.getLayer x).name
		append arrOff layerName
		)catch()
	)
	
)

)
else 
(
	
for i=0 to LayerManager.count-1 do (LayerManager.getLayer i).on = true 
for o=1 to arrOff.count do 
	(
		TestLayer = (LayerManager.getLayerFromName arrOff[o])
		if TestLayer !=undefined do
		(TestLayer.on = false)
	)

)

)

fn SaveLoadINI Arr: INIFilePath: CatName: VarName: Content: Load:false SingleItem: Del:false =
(
	if Del == true then
	(
		delIniSetting INIFilePath CatName VarName
	)
	
	else
	(
	options.printallelements = true 
	if Load == true then
	(
	try (
	LoadFiles = (getIniSetting INIFilePath CatName)
	for i = 1 to LoadFiles.count do (append Arr LoadFiles[i])
	append SingleItem (getIniSetting INIFilePath CatName VarName)
	)catch()
	)
	else 
	(
	
	setINISetting INIFilePath CatName VarName (Content as string)

	)
	options.printallelements = false
    )
)

fn WriteRoot =
(
	ReadWriteIniToRoot StringContent:FileSections FilePath:IniFilePath Write:false
)

fn LoadInINI_beauty_pass =
(
	SaveLoadINI Arr:INIFileCats INIFilePath:INIFilePath CatName:"beauty_pass" VarName:"" Content:"" Load:true SingleItem:""
)

fn LoadInINI_FG =
(
	SaveLoadINI Arr:INIFileCats INIFilePath:INIFilePath CatName:"FG_objects" VarName:"" Content:"" Load:true SingleItem:""
)

fn LoadInINI_People_cars =
(
	SaveLoadINI Arr:INIFileCats INIFilePath:INIFilePath CatName:"People_Cars" VarName:"" Content:"" Load:true SingleItem:""
)



fn SaveINI NameLayer: CatUsed: Content: =
(
	SaveLoadINI Arr:INIFileCats INIFilePath:INIFilePath CatName:CatUsed VarName:NameLayer Content:Content Load:false SingleItem:""
)

fn MakeINI SaveOutPath: =
(
--      createFile SaveOutPath
	SaveLoadINI Arr:"" INIFilePath:SaveOutPath CatName:"beauty_pass" VarName:"" Content:"" Load:false SingleItem:""
	SaveLoadINI Arr:"" INIFilePath:SaveOutPath CatName:"FG_objects" VarName:"" Content:"" Load:false SingleItem:""
	SaveLoadINI Arr:"" INIFilePath:SaveOutPath CatName:"People_Cars" VarName:"" Content:"" Load:false SingleItem:""
)

 try(destroydialog Layermaker) catch() 

 rollout Layermaker "Layer Sets" 
 (

	dropdownlist cat "Cataagory" items:#("beauty_pass", "FG_objects", "People_Cars")
	edittext AddItem "Name"
	button SaveINIitem "Save Layer State"
	listbox Layers "" items:INIFileCats
	button Updat "Update Selected State"
	button Del "Delete Selected State"
	 
	 


	--Reload functions 
	 fn reLoad = 
		(
			Layers.items = INIFileCats
		)
		
			--new function added to reload lists
	fn reloadList =
	(
		
		INIFileCats = #()
		 
		 if cat.selection == 1 do --beauty_pass
		(
		 LoadInINI_beauty_pass()
			
		)
		
		if cat.selection == 2 do --FG
		(
		 LoadInINI_FG()

		)
		
		if cat.selection == 3 do --People_Cars
		(
		 LoadInINI_People_cars()

		)
		
	)
	
	on cat selected i do
	(
		 INIFileCats = #()
		 
		 if cat.selection == 1 do --beauty_pass
		(
		 LoadInINI_beauty_pass()
		 CatName = "beauty_pass"
			
		)
		
		if cat.selection == 2 do --FG
		(
		 LoadInINI_FG()
		 CatName = "FG_objects"

		)
		
		if cat.selection == 3 do --People_Cars
		(
		 LoadInINI_People_cars()
		 CatName = "People_Cars"

		)
		
		 reLoad()
	)
	
	--loading in layers
	on Layers selected i do
	(
		Item =#()
		SaveLoadINI Arr:INIFileCats INIFilePath:INIFilePath CatName:CatName VarName:(INIFileCats[Layers.selection]) Content:"" Load:true SingleItem:Item
		Arr = execute Item[1]
		
		RecordLayerState arrOff:Arr record:false
	)
	
		
	 --UI buttons
	
	on Del pressed do
	(
		
		if querybox "Delete Set?" then 
		(
			try (
		UpdateName = INIFileCats[layers.selection]
		print UpdateName
		SaveLoadINI Arr:"" INIFilePath:INIFilePath CatName:CatName VarName:UpdateName Content:LayerState Load:false SingleItem:"" Del:true
			)catch()
			
		WriteRoot()
			reloadList()
			reLoad()
			
		)
		
	)
	
	
	on Updat pressed do
	(
-- 		if querybox "Update Selected?" then 
-- 		(
		try (
		LayerState =#()
		
		UpdateName = INIFileCats[layers.selection]
		
		RecordLayerState arrOff:LayerState record:true
		SaveLoadINI Arr:"" INIFilePath:INIFilePath CatName:CatName VarName:UpdateName Content:LayerState Load:false SingleItem:""
		)catch()
		
		WriteRoot()
-- 	)
		
	)
	
	
	on SaveINIitem pressed do
	(
		LayerState =#()
				try(
		if AddItem.text != "" then (

		RecordLayerState arrOff:LayerState record:true
		SaveLoadINI Arr:"" INIFilePath:INIFilePath CatName:CatName VarName:AddItem.text Content:LayerState Load:false SingleItem:""
		) else (messagebox "Please Name!"))catch()
		
	    WriteRoot()
		reloadList()
		reLoad()
	)
	
	on Layermaker open do
	(
		FileSections = "[beauty_pass] \n [FG_objects] \n [People_Cars]"
		ReadWriteIniToRoot StringContent:FileSections FilePath:IniFilePath Write:true
	)
	 

 ) 
 CreateDialog Layermaker