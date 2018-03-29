--run this
(
	global rltElementsToObjects
	try destroyDialog rltElementsToObjects catch()
	
	local start_objs = objects as array
	
	fn detach_elems obj base_name = (
		if convertToPoly obj != undefined do (
			while polyOp.getNumFaces obj != 0 do (
				local f_list = polyOp.getElementsUsingFace obj #{1}
				local elem = polyOp.detachFaces obj f_list asNode:true name:(uniqueName base_name)
			)
			delete obj
		)
	)
	
	fn reset_pivots coll = (
		centerPivot coll
		worldAlignPivot coll
		resetXForm coll
		convertToPoly coll
	)
	
	fn invert_set coll = (
		return (for obj in objects where findItem coll obj == 0 collect obj)
	)
	
	rollout rltElementsToObjects "Elements to Objects" width:180
	(
		editText etBaseName "As:" text:"Object" fieldWidth:70 across:2
		button btnDetach "Detach" align:#right
		
		on btnDetach pressed do with undo "Elements to Objects" on (
			local the_name = etBaseName.text
			local the_objs = for obj in selection where superClassOf obj == geometryClass collect obj
			for obj in the_objs do detach_elems obj the_name
			reset_pivots (invert_set start_objs)
		)
	)	
	
	createDialog rltElementsToObjects
)