
thisscriptpath = getFilenamePath (getThisScriptFilename())
FileIn (thisscriptpath+"materialAdapter.mse")
thisxmlpath = thisscriptpath+"MaterialLibrary\\materialdefinitions.xml"	
fn applyMatsToAnima =
(

	local transforMyMaterial=#()

	local objsSharingMaterial=#()
	
	local alreadyAddedMats=#()
		
	
	local numobjs=selection.count
	
	for i=1 to numobjs do
	(
		if (classof selection[i])==anima2scene and selection[i].isdeleted==false then	
		(		
			local numSubChildren =selection[i].actornodes.count 
			
			for j=1 to numSubChildren do
			(
				if(selection[i].actornodes[j]!=undefined) then
				(
					if (classof selection[i].actornodes[j])==anima2actor and selection[i].actornodes[j].isdeleted==false then	
					(
						--MessageBox (selection[i].actornodes[j].material as string)
						local findAt=findItem alreadyAddedMats selection[i].actornodes[j].material
						if(findAt==0) then
						(
							if(selection[i].actornodes[j].material!=undefined) then 
							(
								append alreadyAddedMats selection[i].actornodes[j].material
								append transforMyMaterial selection[i].actornodes[j]
								append objsSharingMaterial #(selection[i].actornodes[j])
							)
						)
						else
						(
							append objsSharingMaterial[findAt] selection[i].actornodes[j]
						)
					)
				)
			)
		)
		if (classof selection[i])==anima2escalator then	
		(
			if(selection[i].material!=undefined ) then
			(
				local findAt=findItem alreadyAddedMats selection[i].material
				if(findAt==0) then 
				(
					append alreadyAddedMats selection[i].material
					append transforMyMaterial selection[i]
					append objsSharingMaterial #(selection[i])
				)
				else
				(
					append objsSharingMaterial[findAt] selection[i]
				)
			)
		)
	)
	
	
	if(transforMyMaterial.count==0) then
	(
		numobjs=objects.count
		for i=1 to numobjs do
		(
			if (classof objects[i])==anima2actor and objects[i].isdeleted==false then	
			(
				if(objects[i]!= undefined and objects[i].material!=undefined) then 
				(					
					local findAt=findItem alreadyAddedMats objects[i].material
					if(findAt==0) then
					(
						append alreadyAddedMats objects[i].material
						append transforMyMaterial objects[i]
						append objsSharingMaterial #(objects[i])
					)
					else
					(
						append objsSharingMaterial[findAt] objects[i]
					)
				)
			)	
			if (classof objects[i])==anima2escalator then	
			(
				if(objects[i].material!=undefined) then 
				(
					local findAt=findItem alreadyAddedMats objects[i].material
					if(findAt==0) then 
					(
						append alreadyAddedMats objects[i].material
						append transforMyMaterial objects[i]
						append objsSharingMaterial #(objects[i])
					)	
					else
					(
						append objsSharingMaterial[findAt] objects[i]
					)		
				)
			)
		)
	)
	
	if(transforMyMaterial.count>0) then
	(
		mainMaterialAdapter thisxmlpath transforMyMaterial objsSharingMaterial
	)		
	return ok
)

applyMatsToAnima()