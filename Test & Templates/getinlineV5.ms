(
	state_ok = undefined
	StartObj = undefined
	EndObj = undefined
	
	fn	state_ok = 
	(
	  for obj in selection do
		if (obj.name == StartObj.name or
			obj.name == EndObj.name) do return false
	 
		return true
	)
		
	rollout rlDistribute "Get In Line" 
	(	
		groupbox gpbxGeneralParameters "General Parameters" width:180 height:120 pos:[10,6]
		label lbStartObj "Start Object:" pos:[19,26]
		label lbStartObjDis "" style_sunkenedge:true height:20 width:140 pos:[19,46]
		pickbutton pkbtnStart "+" width:20 height:20 pos:[160,46]
		label lbEndObj "End Object:" pos:[19,76]
		label lbEndObjDis "" style_sunkenedge:true height:20 width:140 pos:[19,96]
		pickbutton pkbtnEnd "+" width:20 height:20 pos:[160,96]
		groupbox gpbxDisType "Distribution Types" width:180 height:46 pos:[10,130]
		label lbDisType "Types:" pos:[19,150]
		radiobuttons rbtnDisType "" labels:#("Random","Custom","Even") columns:3 default:3 pos:[17,150]
		groupbox gpbxCustomSettings "Custom Settings" width:180 height:46 pos:[10,180]
		label lbCustomAxis "Align Axis:" pos:[19,200] enabled:false
		checkbox ckbxCustomX "X" pos:[96,200] enabled:false
  		checkbox ckbxCustomY "Y" pos:[126,200] enabled:false
  		checkbox ckbxCustomZ "Z" pos:[156,200] enabled:false
 		groupbox gpbxOffset "Offsets" width:180 height:88 pos:[10,230]
		label lbPosOffset "Position:" pos:[19,250]
  		checkbox ckbxX "X" pos:[96,250]
  		checkbox ckbxY "Y" pos:[126,250]
  		checkbox ckbxZ "Z" pos:[156,250]
 		label lbPositionMin "Position Min:" pos:[19,270]
 		label lbPositionMax "Position Max:" pos:[19,290]
  		spinner spnMinOffset "" range:[-999999,999999,-6] fieldwidth:75 type:#worldunits pos:[93,270]
  		spinner spnMaxOffset "" range:[-999999,999999,6] fieldwidth:75 type:#worldunits pos:[93,290]
 		button btnDistribute "Distrube Selected" width:180 height:26 pos:[10,324] enabled:false
		
		on rbtnDisType changed state do
		(
			if rbtnDisType.state == 2 then (lbCustomAxis.enabled = ckbxCustomX.enabled = ckbxCustomY.enabled = ckbxCustomZ.enabled = true )else(lbCustomAxis.enabled = ckbxCustomX.enabled = ckbxCustomY.enabled = ckbxCustomZ.enabled = false)
		)
		
		on pkbtnStart picked obj do
		(
			lbStartObjDis.text = obj.name
			StartObj = obj
			if EndObj != undefined then
			(
				btnDistribute.enabled = true
			)
		)
		
		on pkbtnEnd picked obj do
		(
			lbEndObjDis.text = obj.name
			EndObj = obj
			if StartObj != undefined then
			(
				btnDistribute.enabled = true
			)
		)
		
		on btnDistribute pressed do
		(
			if state_ok() then 
			(
				undo on
				(
					startPos = StartObj.pos
					endPos = EndObj.pos
					selCount = (selection.count)
					
					for i=1 to (selCount) do 
					(		
						evenPos = (startPos + ((endPos-startPos)*(((i as float)/(selCount+1)))))
						randomPos = (startPos + ((endPos-startPos)*(random .001 .999)))							
						obj = Selection[i]
						case rbtnDisType.state of (
							1:(obj.pos = randomPos)
							2:(
									if ckbxCustomX.checked == true do (obj.pos.x = evenPos.x)
									if ckbxCustomY.checked == true do (obj.pos.y = evenPos.y)
									if ckbxCustomZ.checked == true do (obj.pos.z = evenPos.z)
								)
							3:(obj.pos = evenPos )
							)
						if ckbxX.checked == true do (obj.pos.x = (obj.pos.x + (random spnMinOffset.value spnMaxOffset.value)))
						if ckbxY.checked == true do (obj.pos.y = (obj.pos.y + (random spnMinOffset.value spnMaxOffset.value)))
						if ckbxZ.checked == true do (obj.pos.z = (obj.pos.z + (random spnMinOffset.value spnMaxOffset.value)))
					)
				)
			)else(messagebox "Make sure the 'Start' or 'End' objects are NOT selected!")
		)
	)
	createDialog rlDistribute 200 360
)