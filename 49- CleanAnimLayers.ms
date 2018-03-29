try(destroydialog AnimLayerCleanup)catch()
	rollout AnimLayerCleanup "Anim Layer Cleaner"
	(
		button GetLayerNum "How Many layers?" 
		edittext LayerNumbers "Layer Numbers : " fieldwidth: 50 labelOnTop: false
		button CleanLayers "Clean!"
		button CleanMotionClips "Clean MotionClips"
	
		On GetLayerNum pressed Do 
			(
				try
				(
				LayerNumbers.text = (getproperty trackviewnodes.Anim_Layer_Control_Manager.controller #animlayers).count as string
				)
				catch
				(
					LayerNumbers.text = "OK"
				)
			)
			
		On CleanLayers pressed Do
			(
				try
				(
				(getproperty trackviewnodes.Anim_Layer_Control_Manager.controller #animlayers).count=0
				LayerNumbers.text = (getproperty trackviewnodes.Anim_Layer_Control_Manager.controller #animlayers).count as string
				)
				catch
				(
					LayerNumbers.text = "OK"
				)
			)
		On CleanMotionClips pressed Do
			(
				try
				(
				t=trackviewnodes;n=t[#Max_MotionClip_Manager];deleteTrackViewController t n.controller;gc()
				)
				catch
				(
					
				)
			)
	)
	createdialog AnimLayerCleanup