macroScript CopyMat category:"BDW" buttonText:"CopyMat" Tooltip:"CopyMat"
(
	
	try(
	Sel =(selection as array)	
	if sel.count !=0 then 
	(
		 
		objs = pickobject()
		m= objs.material
		sel.material = M
		
		if querybox  "Add UVW?" then
		(
		
			ModtoCopy = objs.modifiers[#UVW_Map]
			if 	ModtoCopy != undefined do
			(
			addmodifier $ ModtoCopy
			)
			ModtoCopy1 = objs.modifiers[#VrayDisplacementMod] 
			if 	ModtoCopy1 != undefined do
				
			(
			addmodifier $ ModtoCopy1
			)
	
		)

	) else (messagebox "no object picked"))catch()
	
)