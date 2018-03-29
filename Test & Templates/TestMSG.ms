LoadMaxFile  @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Material_RenderScene.max"

mergeMAXFile  @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\TempMaxFile.max" 

Category = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Category.ms"
fo = (openFile Category mode:"r")
CATRead = readLine fo
close fo


select $MatHolder

MatHolder = $MatHolder

SourceMaterial = MatHolder.material
MatName = SourceMaterial.name

MatHolderUVW = MatHolder.modifiers[#UVW_Map]
MDummy = $MaterialDummy
if MatHolderUVW == undefined then
	(
MatHolderUVWmod = UVWMap()
addModifier MDummy MatHolderUVWmod
		if (getclassinstances Bitmaptexture)[1] != undefined then
		(
		if  (getclassinstances Bitmaptexture)[1].coords.realWorldScale then
			(
				MatHolderUVWmod.realWorldMapSize = true
				MatHolderUVWmod.maptype = 4
			)
			else(
				MatHolderUVWmod.realWorldMapSize = False
				MatHolderUVWmod.maptype = 4
				MatHolderUVWmod.height = 2000
				MatHolderUVWmod.length = 2000
				MatHolderUVWmod.width = 2000
				)
			)
	)

MDummy.material = SourceMaterial

Delete MatHolder

actionMan.executeAction 0 "40068" 


 f_name= @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + CATRead + @"\" + MatName + ".mat" + ".jpg"
rendSaveFile = True
PreviewDir = (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + CATRead)
makedir PreviewDir
Render outputfile:f_name

-- clearUndoBuffer()
-- resetMaxFile #noPrompt
-- quitMax #noPrompt
	
((dotnetClass "System.Diagnostics.Process").GetCurrentProcess()).Kill()



