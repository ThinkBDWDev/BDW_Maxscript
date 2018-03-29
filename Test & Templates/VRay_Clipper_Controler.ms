SetArrayList = #()
SetsArray = selectionSets
for i = 1 to SetsArray.count do
	(
	SetArrayList[i] = (SetsArray[i]	as string)
	)



Rollout Clipper "Clipper Tool"
(

listbox SelSetsList items:SetArrayList
button AddClipper "Add Clipper"
	
	
	
on SelSetsList selected A do
	(

		 select selectionSets[SelSetsList.selection]
-- 		print SelSetsList.selection
	)
	
	

on AddClipper pressed do
		(	
		groups = for o in helpers where isGroupHead o collect o
		while groups.count > 0 do
		(
			ungroup groups[groups.count] ; groups.count = groups.count-1
		)
		
		SelectionGEO = selection as array
		VRC = VRayClipper isSelected:on
		VRC.name = uniquename "VRClipper_"
				
		SelSet = SelectionGEO + VRC
		
		selectionSets [VRC.name] = SelSet
		VRC.includeList = SelectionGEO
		VRC.position = selectionSets [VRC.name].center
		
		with animate on
		(
			at time (0) VRC.position.z = selectionSets [VRC.name].min.z
			at time (50) VRC.position.z = selectionSets [VRC.name].max.z
		)
		
				SetArrayList = #()
		SetsArray = selectionSets
		for i = 1 to SetsArray.count do
			(
	SetArrayList[i] = (SetsArray[i]	as string)
			)
		SelSetsList.items = SetArrayList
		
			)

 
)createdialog Clipper width:250