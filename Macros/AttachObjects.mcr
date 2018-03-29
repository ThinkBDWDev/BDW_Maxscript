fn AtachSplinePoly ArrItems: SELOBJ: =
(
	Arr = ArrItems
	SEL = SELOBJ

	for i = 1 to Arr.count do
	(
		try
		(
			if classOf Arr[i] == EditablePolyMesh do
			(
			 polyOP.attach SEL Arr[i]
			)
			
			if classOf Arr[i] == SplineShape do
			(
			  addAndWeld SEL Arr[i] 1000000
			)
		)catch()
	)

)

macroScript AtachSplinePoly
	category:"BDW"
	toolTip:"AtachSplinePoly"
	
(

 AtachSplinePoly ArrItems:(selection as array) SELOBJ:(pickobject())
	
)