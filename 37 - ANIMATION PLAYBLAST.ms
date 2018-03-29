

-- RenderPaths = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\TimeLogs\"
RenderPathFolders = getdirectories @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\TimeLogs\*"

RenderPathsUI = #()
for i=1 to RenderPathFolders.count do
(
	RenderPathsUI[i] =  (filterstring RenderPathFolders[i] @"\")[7]
	)
	
	
global Cams = #()
Cams = for i in cameras where classof i == VRayPhysicalCamera or classof i == Freecamera  collect i
	

CamNames = #()
for i=1 to Cams.count do
(CamNames[i] =Cams[i].name)	
	
	

try(destroydialog Playblast_Dial)catch()
	rollout Playblast_Dial ""
	(
		dropdownlist UserSelection items:RenderPathsUI
		listbox PlayblastFolders 
		multilistbox CamsList "Cameras" 
		button PlayBlast "Create Previews" height:50 width:135
		progressbar CurrentCamProg color:red
		progressbar TotalProg color:blue
		
		fn createPreviews = 
				(
			Loop = 0
			if framerate != 25 then (messagebox "your scene is not set to 25 FPS!!")

			else(

					
			Temp	= #()
			Temp = (selection as array)

			if Temp.count == 0 then
			(
			actionMan.executeAction 0 "40247"
			Temp = (selection as array)
			)


			hide cameras
			hide shapes
			hide Lights
			hide helpers


			if viewport.getShowEdgeFaces() == false then(
			viewport.SetShowEdgeFaces true)

			NitSett = NitrousGraphicsManager.GetActiveViewportSetting()
			NitSett.VisualStyleMode = #clay

			completeredraw()

			for i in Temp do 
					(
					
			-- 		if keyboard.escPressed then
			-- 		exit with (prog.value = 0; format "The Script Stoped\n")
					Loop += 1 
					select i
					CamName = $.Name
					viewport.setType #view_camera --Set Viewport to camera
					num_keys = numkeys $.position.controller 
					StartKey = getkeytime $.position.controller 1
					EndKey = StartKey
				
					for i = 1 to num_keys do
						(key_time = getkeytime $.position.controller i
					if key_time > EndKey then
						EndKey = key_time)
									
						rendStart = Startkey
						rendEnd = Endkey						
						animationRange = interval StartKey EndKey
					makeDIr (maxfilepath  +"Previews"+@"\"+CamName)	
					RenCamDir = maxfilepath  +"Previews" +@"\"+CamName + @"\"+ CamName 
					 view_size = getViewSize()
					 
					 for t = animationrange.start to animationrange.end do
					 (
					  sliderTime = t
					  global anim_bmp = bitmap view_size.x view_size.y filename:(RenCamDir + "_" + (((t as integer) /192)as string)+ ".png")
					  dib = gw.getViewportDib()
					  copy dib anim_bmp
					  save anim_bmp gamma:2.2
					  CurrentCamProg.value = 100*t/animationrange.end 
			-- 		  if keyboard.escPressed then
			-- 		  exit with (prog.value = 0; format "The Script Stoped\n")
					 )
					 TotalProg.value = 100*Loop/Temp.count 
					 
					 
					 CurrentCamProg.value = 0
					 close anim_bmp
					 gc()
					 
						
				 )
				 
			TotalProg.color = green	 
				 
			unhide cameras
			unhide shapes
			unhide Lights
			unhide helpers


			NitSett = NitrousGraphicsManager.GetActiveViewportSetting()
			NitSett.VisualStyleMode = #shaded
			viewport.SetShowEdgeFaces false
			completeredraw()

				 
				 
			 )		
			)
					
		fn SelectionChanged =
		(
			CamsList.selection = for j in selection collect finditem CamsList.items j.name
			global Cams = Cams = for i in cameras where classof i == VRayPhysicalCamera or classof i == Freecamera  collect i
			CamNames = #()
			for i=1 to Cams.count do
			(CamNames[i] =Cams[i].name)
			CamsList.items = CamNames
-- 			CamsList.height = Cams.count
			)
			
		on PlayBlast pressed do
		(createPreviews())
			
		on Playblast_Dial open do CamsList.items = CamNames
		on UserSelection selected P do
			(
				PBFolders = getdirectories (@"\\CGISERVER\BDWRenderC\CGIRender\" + (RenderPathsUI[P]) + @"\*")
				print RenderPath
				
				PBFoldersUI = #()
				PlayblastFolders.items = #()
				for i=1 to PBFolders.count do
					(
						PBFoldersUI[i] = (filterstring PBFolders[i] @"\")[5]
						print PBFoldersUI[i]
						
						)
				
				PlayblastFolders.items = PBFoldersUI	
			)
		
		on  CamsList selected o do
			(
			print CamsList.selection
			selNames = for i in CamsList.selection collect CamsList.items[i]
			print o
			select (for j in CamsList.selection collect getnodebyname CamsList.items[j])
			
			)
		on CamsList rightclick o do
		(
			clearselection()
			CamsList.selection = #{}
			)
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	)
	createdialog Playblast_Dial -- width: height:










/*




fn createPreviews = 
	(

if framerate != 25 then (messagebox "your scene is not set to 25 FPS!!")

else(

		
Temp	= #()
Temp = (selection as array)

if Temp.count == 0 then
(
actionMan.executeAction 0 "40247"
Temp = (selection as array)
)


hide cameras
hide shapes
hide Lights
hide helpers


if viewport.getShowEdgeFaces() == false then(
viewport.SetShowEdgeFaces true)

NitSett = NitrousGraphicsManager.GetActiveViewportSetting()
NitSett.VisualStyleMode = #clay

completeredraw()

for i in Temp do 
		(
		
-- 		if keyboard.escPressed then
-- 		exit with (prog.value = 0; format "The Script Stoped\n")
		
		select i
		CamName = $.Name
		viewport.setType #view_camera --Set Viewport to camera
		num_keys = numkeys $.position.controller 
		StartKey = getkeytime $.position.controller 1
		EndKey = StartKey
	
		for i = 1 to num_keys do
			(key_time = getkeytime $.position.controller i
		if key_time > EndKey then
			EndKey = key_time)
						
			rendStart = Startkey
			rendEnd = Endkey						
			animationRange = interval StartKey EndKey
		makeDIr (maxfilepath  +"Previews"+@"\"+CamName)	
		RenCamDir = maxfilepath  +"Previews" +@"\"+CamName + @"\"+ CamName 
		 view_size = getViewSize()
		 
		 for t = animationrange.start to animationrange.end do
		 (
		  sliderTime = t
		  global anim_bmp = bitmap view_size.x view_size.y filename:(RenCamDir + "_" + (((t as integer) /192)as string)+ ".png")
		  dib = gw.getViewportDib()
		  copy dib anim_bmp
		  save anim_bmp gamma:2.2
-- 		  if keyboard.escPressed then
-- 		  exit with (prog.value = 0; format "The Script Stoped\n")
		 )
		 close anim_bmp
		 gc()
			
	 )
	 
unhide cameras
unhide shapes
unhide Lights
unhide helpers


NitSett = NitrousGraphicsManager.GetActiveViewportSetting()
NitSett.VisualStyleMode = #shaded
viewport.SetShowEdgeFaces false
completeredraw()

	 
	 
 )		
)
				
