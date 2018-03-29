 /*Rotate DomeLigh Vray ***************************
 
  
 
  */
 
 try(destroydialog LighRotate) catch() 
 
 rollout LighRotate "Rotate DomeLight" 
 (
	  button Run_btn "RotateDome"
	 
	 on Run_btn pressed do
	 (
		 
		Cam = getactivecamera()

		if Cam != undefined do
		(
			
			CamName = Cam.name
			CamString = filterstring CamName "[]"
			CamNumber = if CamString.count ==2 then (CamString[2] as float) else(undefined)
			
			if CamNumber != undefined do
				(
				
						for o in lights where ClassOf o == vraylight do
						(
							if o.type==1 then (o.rotation.z_rotation = CamNumber)		
						)
				
				)
			
		) 
		 		 
	 )
	 
	 

 ) 
 CreateDialog LighRotate