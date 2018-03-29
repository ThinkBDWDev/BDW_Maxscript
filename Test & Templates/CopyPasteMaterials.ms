--CopyMat


viewNode = sme.GetView (sme.activeView)
smeSelMats = #()
for n = 1 to trackViewNodes[#sme][(sme.activeView)].numSubs do (
m = trackViewNodes[#sme][(sme.activeView)][n].reference 
b = viewNode.GetNodeByRef m
if b.selected and superclassof m == material do append smeSelMats m
)

	thecopypastedir = getdir #autoback
	thecopypastefile = "\pastematfile.mat" --this is the filename to save as...
	thecopypastestring = thecopypastedir + thecopypastefile --this is the complete string

-- 	selectedmat=medit.GetCurMtl()
	pastelib=loadTempMaterialLibrary thecopypastestring	
		if pastelib == undefined then (
			loadDefaultMatLib			
			saveTempMaterialLibrary currentMaterialLibrary thecopypastestring
			pastelib=loadTempMaterialLibrary thecopypastestring
		)
		
		for i=1 to pastelib.count do(
		deleteitem pastelib (i)
		)
	--currentMaterialLibrary
	append pastelib smeSelMats[1]
	saveTempMaterialLibrary pastelib thecopypastestring
	--if $ != undefined do 
		--saveNodes $ thecopypastestring --this saves ("copies") the objects as a file

--PasteMat
		
		
-- /*		
		
	thecopypastedir = getdir #autoback 
	thecopypastefile = "\pastematfile.mat" 
	thecopypastestring = thecopypastedir + thecopypastefile
    
	pastelib=loadTempMaterialLibrary thecopypastestring
	selectedmatslot= activeMeditSlot
	pastedmat=pastelib[1]
	setMeditMaterial selectedmatslot pastedmat
	NewMat = getmeditmaterial selectedmatslot
	TempOBJ = Sphere radius:45.7799 
	TempOBJ.material = NewMat
	NewView = sme.GetView (sme.activeView)
	NewView.CreateNode TempOBJ.material[0,0]
	delete TempOBJ
		
		
-- */