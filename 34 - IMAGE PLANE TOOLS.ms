
/*
Plane Tools




*/

CreationView = (angleaxis 0 [1,0,0])


try(destroydialog PlaneTools)catch()
	rollout PlaneTools""
	(
		button GetIMGPath "Select Image" 
		radiobuttons View "" labels:#("T","R","L","F") columns:4
		
		
		on GetIMGPath pressed do
			(
				ImagePath = getOpenFileName caption:"Select Image File:" historyCategory:"CAD Images"
				Imagemap = openbitmap ImagePath
				PlaneGeo = Plane width:Imagemap.width length:Imagemap.height
				PlaneGeo.rotation = CreationView
				PlaneGeo.position = [0,0,-100]
				BitmapNode = bitmaptex name:"CadTexture"
				BitmapNode.fileName = ImagePath
				Mat = VRayMtl name:"PlaneCad" 
				PlaneGeo.material = Mat
				Mat.texmap_diffuse = BitmapNode
				showTextureMap Mat on
			)
		
		on View changed P do
			(
				if P == 1 then(CreationView = (angleaxis 0 [1,0,0]))
				if P == 2 then(CreationView = (angleaxis 90 [0,1,0]))
				if P == 3 then(CreationView = (angleaxis -90 [0,1,0]))
				if P == 4 then(CreationView = (angleaxis 90 [1,0,0]))
			)
		
		
	)
	createdialog PlaneTools -- width: height:
	
	
