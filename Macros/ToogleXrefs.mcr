macroScript ToogleXrefs
category:"BDW"
toolTip:"Toggle Xrefs"
(
	local xref_max_index = xrefs.getXRefFileCount()
	--array
	for i =1 to xref_max_index do
	(
		this_xref = xrefs.getXrefFile i
		if this_xref.hidden == false then ( this_xref.hidden = true) else ( this_xref.hidden =  false)
		)
	)
