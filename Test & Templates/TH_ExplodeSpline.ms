/*
	Tronotools Detach all elements Spline v1.0
	www.hille3d.no / tronotrond@gmail.com
	
	created:		2016/04/27
	last modified:	2016/04/27


*/

_localSplineProgress = 0.0

fn GetSelectedSplines = 
(
	_splineArray = (for spl in $selection where superClassOf spl == Shape collect spl)
	_splineArray
)

fn DetachElements myShape =
(
	--ProgressStart "Exploding Shape"
	
	num = myShape.numsplines
	_name = myShape.name
	
	for _spl = 1 to num do
	(
		_newspl = SplineShape()
		_newspl.name = (_name + (_spl as string))
		addnewspline _newspl
		
		for i = 1 to (numKnots myShape _spl) do
		(
			knotPoint = getKnotPoint myShape _spl i
			segType = getSegmentType myShape _spl 1
			knotType = getKnotType myShape _spl i
			
			if knotType == #bezier OR knotType == #bezierCorner then
				addKnot _newspl 1 knotType segType knotPoint (getInVec myShape _spl i ) (getOutVec myShape _spl i)
			else
				addknot _newspl 1 knotType segType knotPoint
		)
		
		if (isClosed myShape _spl) then 
			close _newspl 1
		
		updateshape _newspl
		--ProgressUpdate (100.0*_spl/num)
		_localSplineProgress = (100.0*_spl/num)
	)
	delete myShape
	--progressEnd()
)

rollout ttExplodeSpline "Explode Spline" width:144 height:136
(
	button 'btn1' "Explode Spline Selection" pos:[8,8] width:128 height:24 align:#left
	checkbox 'chk1' "Undo On" pos:[8,40] width:64 height:16 align:#left
	
	label 'lbl1' "Overall Progress" pos:[8,64] width:120 height:16 align:#left
	progressBar 'pb1' "ProgressBar" pos:[8,80] width:128 height:16 color:(color 0 255 0)align:#left
	label 'lbl2' "Spline" pos:[8,96] width:120 height:16 align:#left
	progressBar 'pb2' "ProgressBar" pos:[8,112] width:128 height:16 color:(color 30 10 190) align:#left
	
	
	
	fn ExplodeSplines SplineArray = 
	(
		for i = 1 to SplineArray.count do
		(
			lbl2.text = ("Exploding spline " + (i as string) + " of " + (SplineArray.count as string))
			DetachElements(SplineArray[i])
				
			pb1.value = (100.0*i/SplineArray.count)
			pb2.value = _localSplineProgress
		)
		lbl2.text = "Done!"
	)
	
	on btn1 pressed do
	(
		_array = #()
		_array = GetSelectedSplines()
		DisableSceneRedraw()
		if chk1.checked == true then
		(
			undo on 
			(
				ExplodeSplines(_array)
			)
		)
		else 
		(
			undo off
			(
				ExplodeSplines(_array)
			)
		)
		EnableSceneRedraw()
		
	)
)

try (DestroyDialog ttExplodeSpline) catch()
CreateDialog ttExplodeSpline