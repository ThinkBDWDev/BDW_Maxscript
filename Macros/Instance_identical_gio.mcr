
macroScript Instance_Identical_Geometry
	category:"BDW"
	toolTip:"Insatncer"
(
	-- filter selection & get all geometry objects
	local objSet = for i in selection where (getPolygonCount i) as string != "#(0,0)" collect i
	
	on isEnabled return (objSet.count != 0)
	on execute do
	(
		setWaitCursor()
		with redraw off
		(
			while objSet.count > 0 do
			(
				obj = objSet[1]
				deleteItem objSet 1
				-- array of properties to be compared // you could expand it with more...
				srcData = #(
					classOf obj, 
					(getPolygonCount obj) as string, 
					obj.scale
				)
				-- collect identical
				local identical = for i in geometry where \
					not areNodesInstances obj i and \
					classOf i == srcData[1] and \
					(getPolygonCount i) as string == srcData[2] and \
					i.scale == srcData[3] collect i
				-- clean up objSet
				for i in identical do (
					dub = findItem objSet i
					if dub != 0 do deleteItem objSet dub
				)
				instanceReplace identical obj -- mapped
			)
		)
		redrawViews()
		setArrowCursor()
	)
) --//eof