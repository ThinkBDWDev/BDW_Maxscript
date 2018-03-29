

rollout Test "TEST"
(
	checkbutton RenderSettings "Vray" checked:false
		on RenderSettings changed state do
			(
				if state == on then
					(renderscenedialog.open())
				if state == off then
					(renderscenedialog.close())
				)
 
	)
createdialog Test