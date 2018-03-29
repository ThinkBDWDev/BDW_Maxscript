-- viewport.SetFOV 50
-- redrawViews() 	 
CurFOVVal =("Current FOV   : " + (viewport.GetFOV() as string))

try(destroydialog _FOV)catch()
rollout _FOV "Change FOV"
	(
		label CurFOV CurFOVVal
		spinner NewFov "New FOV" type:#float range:[0,360,45]
		button UpdateFOV "Update FOV"
		on UpdateFOV pressed do	
		(
			viewport.SetFOV NewFov.value
			redrawViews() 
			try(destroydialog _FOV)catch()
				
			)
		
		
		)
createdialog _FOV