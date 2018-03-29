Stills_Layers = #()
Stills_Layers = #("#HT Cads", "#HT Model", "#Int_Decor", "#Keep Hidden", "#Siteplan Cads", "#Site_Grass", "#Site_Plants", "#Trees", "#Site_Model")

Int_Layers = #()
Int_Layers = #("#Cads","#Lights","#Exterior Stuff","#Kitchen/Sitting Room","#Hallways","#Bathroom 01","#Bathroom 02","#Bedroom 01","#Bedroom 02","#Plot Geometry", "#Keep Hidden")

Anim_Layers = #()
Anim_Layers = #("#HT Cads", "#HT Model", "#Int_Decor", "#Keep Hidden", "#Siteplan Cads", "#Site_Grass", "#Site_Plants", "#Trees", "#Site_Model","#ENV Trees", "#Animated Cars", "#Animated People")

-- for i = 1 to Stills_Layers.count do
-- 	(
-- 		newLayer = LayerManager.newLayerFromName Stills_Layers[i]
-- 		)


-- messagebox "Test\nTest\n"

CurrentLayers = #()
		
for i = 0 to layerManager.count-1 do
(
  ilayer = layerManager.getLayer i
  layerName = ilayer.name
  CurrentLayers[i+1] = layerName
  format "Layer: % \n" layerName 
)

-- TempLayer = LayerManager.getLayerFromName "#Keep Hidden"
-- TempLayer.on = false
-- TempLayer.renderable = false

try (destroydialog LayersInt)catch()
rollout LayersInt "Layers"
(
imgTag img_header "Header" width:110 height:30 bitmap:(openBitmap @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\LayersBG.jpg") offset:[-2,0] 
listbox Ly "Layers" items:	CurrentLayers --height:layerManager.count
button Stills "Stills" width:120 height:35 Tooltip:"Stills Layer Preset"
button Interiors "Interiors" width:120 height:35 Tooltip:"Interiors Layer Preset"
button Animations "Animations" width:120 height:35 Tooltip:"Animations Layer Preset"
-- button AddObj "+" tooltip:"Add Selection to selected Layer"
	
	
	on Ly rightclick do
		(CurLayer = LayerManager.getLayerFromName Ly.selected
		Curlayer.current = true
		)
			
	on Stills pressed do
		(
			for i = 1 to Stills_Layers.count do
				(
					newLayer = LayerManager.newLayerFromName Stills_Layers[i]
					)
			TempLayer = LayerManager.getLayerFromName "#Keep Hidden"
			TempLayer.on = false
			TempLayer.renderable = false
					::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Updated_Toolbox_Catalog\Scene Tools\25 - LAYER MANAGER.ms" --Reload layer List 
			)
	on Interiors pressed do
		(
			for i = 1 to Int_Layers.count do
				(
					newLayer = LayerManager.newLayerFromName Int_Layers[i]
					)
			TempLayer = LayerManager.getLayerFromName "#Keep Hidden"
			TempLayer.on = false
			TempLayer.renderable = false
					::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\25 - LAYER MANAGER.ms" --Reload layer List 
				)
	on Animations pressed do
		(
			for i = 1 to Anim_Layers.count do
				(
					newLayer = LayerManager.newLayerFromName Anim_Layers[i]
					)
			TempLayer = LayerManager.getLayerFromName "#Keep Hidden"
			TempLayer.on = false
			TempLayer.renderable = false
					::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\25 - LAYER MANAGER.ms" --Reload layer List 
			)			
			

	
-- 	on AddObj pressed do
-- 		(
-- 		LayerID = LayerManager.getLayerFromName Ly.selected
-- 		if selection == undefined then
-- 			(messagebox "Nothing selected")
-- 		else
-- 		for i in selection do
-- 			(LayerID.addnode i)
-- 			)
)
createdialog layersInt width:130 height:350