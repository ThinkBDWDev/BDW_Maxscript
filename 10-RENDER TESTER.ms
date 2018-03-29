try(destroydialog _RenderT)catch()
rollout _RenderT "Render Tester"
(
	button _Quick "QuickR"  across: 2  width:100 height:60  tooltip:"Quick Render Mode"
		on _Quick pressed do
		(
			filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\QuickRender.ms"
			)
		button _Clay "ClayR" across: 2  width:100 height:60 tooltip:"Clay Render Mode"
		on _Clay pressed do
		(
			filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\ClayRender.ms"
			)	
		button _SkySys "Add Sun & Dome"	width:190
			on _SkySys pressed do
				(
			
					MergeMaxFile @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Dont_Touch\LightDayRig.max"

					_TEXTHDRI = $Dome.texmap

			if environmentMap == undefined do
				(
					useEnvironmentMap = true
					environmentMap  = _TEXTHDRI
				)
			)

			button _SaveS "Save State" across: 2 width:100
			on _SaveS pressed do
			
			(
				_FName = maxfilename
				_FNameT = trimright _FName ".max" 
				 global _PresetN =  _FNameT + ".rps"
				renderPresets.saveall 0 (GetDir #renderPresets + @"\" + _PresetN)
			
				)
				
			button _Revert "Revert State" across: 2 width:100
			on _Revert pressed do
				
			(
				renderPresets.loadall 0 (GetDir #renderPresets + @"\" +   _PresetN)
-- 				delete $Dome
-- 				delete $Sun
-- 				delete $FDirect004
					)
			
			

)
createdialog _RenderT width:210 height:130

