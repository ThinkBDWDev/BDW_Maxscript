	
-- 	viewNode = sme.GetView (sme.activeView)
-- smeSelMats = #()
-- for n = 1 to trackViewNodes[#sme][(sme.activeView)].numSubs do (
-- m = trackViewNodes[#sme][(sme.activeView)][n].reference 
-- b = viewNode.GetNodeByRef m
-- if b.selected and superclassof m == material do append smeSelMats m
-- )

-- sme.DeleteView 1 false
Diff = selection[1].name
TabName = uniquename TabName
NewView = sme.GetView(sme.CreateView TabName)

for i in selection do
(
	NewView.CreateNode i.material [0,0]
)
viewNode = sme.GetView (sme.activeView)
viewNode.name =uniquename "Inspection"
actionMan.executeAction 369891408 "40060" 