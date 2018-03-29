----------------------------------------------------------------------------------------
-- Script Name:	ShowMaterialsForSelected.ms
-- Compatible:		Max 2011, 2012, 2013 and 2014
-- Version:		v1.0
-- Release date:   1 April 2014
-- Code by:		Hernan Rodenstein  - www.rode3d.com.ar
----------------------------------------------------------------------------------------

macroScript ShowMaterials category:"Rode3D" tooltip:"Show materials for selected objects"
(
	-- *** Opens the Material Editor and shows just the materials for the selected objects ***
	if (selection.count > 0) then
	(
		sme.Open()
		--DELETE AND CREATE A NEW VIEW
		sme.DeleteView 1 false
		NewView = sme.GetView(sme.CreateView "View1")
		--POPULATE THE VIEW
		for obj in selection do
		(
			NewView.CreateNode obj.material[0,0]
		)
		--ARRANGE THE VIEW
		actionMan.executeAction 369891408 "40060"
	)
	else
	(
		messagebox "You must have at least one object selected!"
	)
)