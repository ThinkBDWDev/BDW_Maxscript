
-- aXref=xrefs.getXRefFile 2
XRsNo = xrefs.getXRefFileCount()

XrefList = #()
XrefParents = #()
NewList = #()
XrefName = #()
for i = 1 to XRsNo do
	(
		
		XrefList[i] = xrefs.getXRefFile i
		XrefName = (Filterstring (XrefList[i] as string) ":" )[2]
		XrefParents[i] = XrefList[i].parent.name
		NewList[i] = (XrefName  as string) + "----------" + (XrefParents[i] as string)
		)
		
try(destroydialog XRList )catch()
	rollout XRList""
	(
		listbox List "" height:75
			fn SelectionChanged = 
			(
			for i = 1 to XRsNo do
			(	
-- 			XrefList[i] = xrefs.getXRefFile i
-- 			XrefName = (Filterstring (XrefList[i] as string) ":" )[2]
			XrefParents[i] = XrefList[i].parent.name
				if $ != undefined and $.name ==  XrefParents[i] then
					(
						List.selection = i
						)
				else()
			)
			)

		
		
		on List selected P do
			(
				select XrefList[List.selection].parent
			)
			
			
	on XRList open do
		(
			
		List.items = NewList
		callbacks.removescripts id:#MLB_Camera_SEL
		callbacks.addscript #selectionSetChanged "XRList.SelectionChanged()" id:#MLB_Camera_SEL

		)

		on XRList close do
		(
		callbacks.removescripts id:#MLB_Camera_SEL

		)
		
	)
	createdialog XRList width:600 -- height:
	
	
	
