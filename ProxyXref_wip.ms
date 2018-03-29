--Temp tool for saad

fn BatchMaxFiles MaxFilesPath: BatchCode_fn: =
(
	MaxPath = MaxFilesPath

	if MaxPath != undefined do
	(
		
		
	  theFiles = getFiles (MaxPath+"\\*.max")
	  for i = 1 to theFiles.count do
	  (
		loadMaxFile theFiles[i] quiet:true 

		BatchCode_fn()
        resetMaxFile #noPrompt
	  )
	    resetMaxFile #noPrompt
	)
)

fn MakeProxMesh =
(
-- 	try(
	arr = #()
	NonHiddenOBJ =#()
	for o in objects where not o.isHiddenInVpt do (append NonHiddenOBJ o)
	select NonHiddenOBJ
	ungroup $
	
	Items = selection as array
		
	for o = 1 to Items.count where ClassOf Items[o] != vrayproxy do
		(

			if SuperclassOf Items[o] == GeometryClass then append arr Items[o]

		)
		

	OBJ = arr[1]
	convertToPoly OBJ
	undo off
	for i = 2 to arr.count do
	(

	  polyOp.attach OBJ arr[i]
		
	)
	undo on 
	
	
	MaxOutput = (maxfilePath + "proxies")
	MakeDir MaxOutput
	MeshFileName = MaxOutput + "/" + (trimright maxFileName ".max") + ".vrmesh"
	select OBJ
	vrayMeshExport meshFile:MeshFileName autoCreateProxies:true exportMultiple:true animation:false
	
	
	savemaxfile (MaxOutput + "/" + maxFileName)
-- 	)catch()	
)


 try(destroydialog BatchProx) catch() 

 rollout BatchProx "Batch Proxy" 
 (
    edittext path_ "path"
	button con "convert"
	 
	 on con pressed do
	 (
		 try(
		 if querybox "Do you want to convert HTs to proxies?!" then 
		 (

					  BatchMaxFiles MaxFilesPath:(path_.text + "/") BatchCode_fn:MakeProxMesh
		)
		)catch()
		
	)
 ) 
 CreateDialog BatchProx style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)