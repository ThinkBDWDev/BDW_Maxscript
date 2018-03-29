


Utility Replacer "Replacer"
	(
	local geom
	local objset = #()
	local objsetcount = 1
	local replaceobj
	local obj_name_array = #()
	local geomlabl
	local ind
	local mmq

	group "Delete old"
		(
		checkbox deleteold "Delete old" checked:true
		)
	group "Replace Geometry" 
		(
		label geomlab1 "Geometry Unselected" 
		listbox geomlist "Replace Objects:" enabled:false height:4
		button pick_geom "Use Selected" width:100 tooltip:"Select one or more objects then press me!"
		)
	
	--Group "Replace With"(
		--pickbutton btnPick "None" width:100
	--)
	Group "Affect"
	(
		radiobuttons radioAffect labels:#("All", "Selected") default:2
	)
	Group "New Objects Type"
	(
		radiobuttons newobjtype labels:#("Copy", "Instance", "Reference")
	)
	Group "Replace Objects"
	(
		button btnGo "Replace" width:100
	)
	
	on pick_geom pressed do		
		( 	
		if selection.count == 0 then messageBox "Please select one or more objects."  beep:false else 
			(
			ind=1
			obj_name_array = #()
			objsetcount = 0
			objset = #()
			for i=1 to selection.count do
				(
				if ( not (isgroupmember selection[i]) or (isgrouphead selection[i]) ) do
					(
					obj_name_array[ind] = selection[i].name
					objset[ind] = selection[i]
					ind += 1
					objsetcount +=1
					)
				)
			geomlist.items = obj_name_array
			geomlab1.text =""
			)
			geomlist.enabled = true
				
			--asigning the array
			--for i in 1 to objsetcount do
			--objset[i] = undefined
			--objsetcount = 0
			--for i in 1 to selection.count do
			--	(
			--	objset[i] = selection[i]
		 	--	objsetcount +=1	
			--	)
		)

	
	on btnGo pressed do
		(
		objarray = #() 
		if RadioAffect.state == 1 then objarray = for obj in objects collect obj
		if RadioAffect.state == 2 then objarray = for obj in selection collect obj
		i = 1
		undo on
		for obj in objarray do
			(
			print objsetcount
			rnd = random 1 objsetcount
			geom = objset[rnd]
			print "geom="
			print geom
			if obj.name != objset[rnd].name do
				(
				if newobjtype.state == 1 do
					(
					if isGroupHead geom then 
						(
						maxops.cloneNodes geom clonetype:#copy newnodes:&newobj
						print newobj
						mmq = 2
						)
					else
						(
						newobj = copy geom
						mmq = 1
						)
					)
				if newobjtype.state == 2 do
					(
					if isGroupHead geom then 
						(
						maxops.cloneNodes geom clonetype:#instance newnodes:&newobj
						print newobj
						mmq = 2
						)
					else
						(
						newobj = instance geom
						mmq = 1
						)
					)
				if newobjtype.state == 3 do
					(
					if isGroupHead geom then 
						(
						maxops.cloneNodes geom clonetype:#reference newnodes:&newobj
						print newobj
						mmq = 2
						)
					else
						(
						newobj = reference geom
						mmq = 1
						)
					)
				print newobj
				if mmq == 2 then
					(
					newobjp = newobj[2].parent
					newobjp.rotation = obj.rotation
					newobjp.pos = [obj.position.x, obj.position.y, obj.position.z]
					print obj.rotation
					print newobjp.rotation
					)
				if mmq == 1 then
					(
					newobj.rotation = obj.rotation
					newobj.pos = [obj.position.x, obj.position.y, obj.position.z]
					print obj.rotation
					print newobj.rotation
					)
				if deleteold.checked == true then delete obj
			)
		)
	)
)