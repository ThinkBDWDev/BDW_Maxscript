try(destroydialog Substituter)catch()
rollout Substituter "Replace OBJ"
(
	pickbutton SrcOBJ "Source Obj"
	button TrgtOBJ "Target Objs"
	Button Rplace "Replace"
	progressbar ProgBar color:green
	
	on SrcObj picked obj do
		(
			global SourceObj = obj 
			SrcObj.text = obj.name
			)
	on TrgtOBJ pressed do
		(	
			global targets = selection as array
			
			if targets.count == 0 then
				(messagebox "Select Taget Objects First\n\n *****************\n\n")
			else
			(
			global targets = selection as array
			TrgtOBJ.text = "CAPTURED"
			)
		)
	on Rplace pressed do
		(
			for i=1 to targets.count do
				(
					ProgBar.value = 100.*i/targets.count
					ClonedSrc = instance SourceObj
					
					ClonedSrc.rotation.x  = targets[i].rotation.x
					ClonedSrc.rotation.y  = targets[i].rotation.y
					ClonedSrc.rotation.z  = targets[i].rotation.z
					ClonedSrc.pos  = targets[i].pos
					delete targets[i]
					)
			
			
			
			
			)
)
createdialog Substituter

