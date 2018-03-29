

RaytraceMaps = getClassInstances Raytrace
if RaytraceMaps.count == 0 then ("no") else 
	
	(
	if querybox "Raytrace Material Found! Do You Want to Remove it?!" then 
		(
			VrayColour = Vraycolor color: (color 60 60 60)
			for raytinst in RaytraceMaps do
			replaceInstances raytinst VrayColour
		) else ("no")
	
	)