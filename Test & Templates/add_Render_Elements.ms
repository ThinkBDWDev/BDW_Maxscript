	

rollout _REui "RenderElements"
(
spinner _AOR "Adjust AO Radius" range:[0,1500,250] align:#right
spinner _AOS "Adjust AO Subdivs" range:[0,64,24] align:#right
	-----------------------------------------------------------------------------
	
button _ADDELE "Add Elements"  height:30 width:180 align:#bottom
	on _ADDELE pressed do
	(
	r = maxOps.GetCurRenderElementMgr()
    -- get current render element
    r.removeallrenderelements() 
		
	r.AddRenderElement (multimatteelement elementname:"MM_01" R_gbufIDOn: true R_gbufID: 111 G_gbufID: 222 B_gbufID: 333); 
	r.AddRenderElement (multimatteelement elementname:"MM_02" R_gbufIDOn: true R_gbufID: 444 G_gbufID: 555 B_gbufID: 666)
	r.AddRenderElement (multimatteelement elementname:"MM_03" R_gbufIDOn: true R_gbufID: 777 G_gbufID: 888 B_gbufID: 999)
	r.AddRenderElement (multimatteelement elementname:"MM_04" R_gbufIDOn: true R_gbufID: 1 G_gbufID: 2 B_gbufID: 3 matid:true)
	r.AddRenderElement (multimatteelement elementname:"MM_05" R_gbufIDOn: true R_gbufID: 4 G_gbufID: 5 B_gbufID: 6 matid:true)
	r.AddRenderElement (multimatteelement elementname:"MM_06" R_gbufIDOn: true R_gbufID:7 G_gbufID: 8 B_gbufID: 9 matid:true)
	r.AddRenderElement (VRayWireColor elementname:"WireColor")
	r.AddRenderElement (VRayLighting  elementname:"Lighting")	
	r.AddRenderElement (VRayNormals elementname:"Normals")
	r.AddRenderElement (VRayReflection elementname:"Reflections")
	r.AddRenderElement (VRayRefraction elementname:"Refraction")
	r.AddRenderElement (VRaySpecular elementname:"Specular")
	r.AddRenderElement (VRayTotalLighting elementname:"TotalLighting")
	r.AddRenderElement (VRayGlobalIllumination elementname:"GI")
    r.AddRenderElement (Alpha elementname:"Alpha")
	r.AddRenderElement (VRayZDepth  elementname:"ZD01" zdepth_min: 10000 zdepth_max: 50000)
	r.AddRenderElement (VRayZDepth  elementname:"ZD02" zdepth_min: 0 zdepth_max: 10000)
	r.AddRenderElement (VRayExtraTex elementname:"VRay AO")
	

        elementCount = r.NumRenderElements()
    
    DR = r.GetRenderElement (elementCount-1)
    DR.texture = VRayDirt radius:_AOR.value subdivs: _AOS.Value
-- 		 destroydialog _REui
		 )

button _RelmP "Set Folder Paths" width:180 height:30
			on _RelmP pressed do
			(
				if renderSceneDialog.isopen() == true then renderSceneDialog.close()
					global Rout = rendOutputFilename 
					global Rout_path_array = undefined
					global Rout_path = undefined
					global Rout_fileName = undefined
					global Rout_fileExt = undefined

					if Rout != "" then
					(
						Rout_path = getFilenamePath Rout
						Rout_fileName = getFilenameFile Rout
					) else messagebox "Please set the render path first"
						
					re = maxOps.GetCurRenderElementMgr()

					NmElements = re.NumRenderElements()

					if ((NmElements > 0) and (Rout != "")) then
					(
					for x = 0 to (NmElements - 1) do
					(
						DirfileNameType = getFilenameType (re.GetRenderElementFilename x)
							
						path3 = re.GetRenderElement x
						ElementfileName2 = path3.elementname
						ElementfileName3 = Rout_fileName + "_" + ElementfileName2 + "_" + DirfileNameType 
						
						makedir (Rout_path+ElementfileName2)
						re.SetRenderElementFilename x (Rout_path+ElementfileName2+"\\"+ElementfileName3)
						
					)
					messageBox "done!"
					renderSceneDialog.open()
					)
					else 
						(
							
							if NmElements == 0 then (messageBox "Please add some render elemens first")
						)
					)


)
 createdialog _REui height:120 width:200 pos:[300,200]