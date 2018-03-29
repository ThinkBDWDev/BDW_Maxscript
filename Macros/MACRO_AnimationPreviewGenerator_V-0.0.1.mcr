macroScript AnimationPreviewGeneratorMacro category:"BDW" tooltip:"Animation Preview Generator " Icon:#("AnimationPreviewGenerator",1)
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
		try(
		if keyboard.escPressed then
		exit with (prog.value = 0; format "The Script Stoped\n")
		
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
		  anim_bmp = bitmap view_size.x view_size.y filename:(RenCamDir + "_" + (((t as integer) /192)as string)+ ".png")
		  dib = gw.getViewportDib()
		  copy dib anim_bmp
		  save anim_bmp
		  if keyboard.escPressed then
		  exit with (prog.value = 0; format "The Script Stoped\n")
		 )
		 close anim_bmp
		 gc())catch(print"Yo YO YO Cool Down")
			
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
