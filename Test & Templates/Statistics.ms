unRegisterRedrawViewsCallback MaterialStatistics

fn MaterialStatistics =
(
	
	
	
	
try (MaterialName = "Material: "+$.material.name) catch(MaterialName = "Material:")
try (ID = "Object ID: "+ ($.gbufferchannel as string)) catch(ID = "Object ID:")
	
try (
	MatIDArray = #()
	objs = selection as array
	if objs.count >= 2 then
		( MatID = "Material ID: Multiple Objects Selected")
		else(
			if classof objs[1].material == Multimaterial then
			(
-- 				MatID = "Material ID: Multimaterial"
				vrmArr = getClassInstances vrayMtl target:objs[1]
				MultiID = #()
				for i=1 to vrmArr.count do
					(
						appendifunique MultiID vrmArr[i].effectsChannel 
						)
				MatID = "Material ID: MultiMat    "+ (MultiID as string)
				)else(
			MatID = "Material ID: "+ (objs[1].material.effectsChannel as string))	
			)) catch(MatID = "Material ID:")
	
	RenderEngine = (filterstring (renderers.current as string) ":")[1]
	
        tf = 0
        sf = 0
        for o in $geometry do
        (
            tf += o.mesh.numFaces
            if o.isSelected do sf += o.mesh.numFaces
        )
        tf = "Total Faces:      " + (dotNetClass "System.String").Format "{0:n0}" tf
        sf ="Selected Faces:      " +  (dotNetClass "System.String").Format "{0:n0}" sf
        ss = stringstream ""
        format "GL:  % (%)" tf sf to:ss
		timeSpan = dotNetClass "TimeSpan"
		formatStr = "hh' : 'mm' : 'ss"
		
gw.wText [10,255,0] MatID color:white --MAT IDS		
gw.wText [10,240,0] ID color:white  -- OBJ IDS
gw.wText [10,225,0] ("Render Engine:   " + RenderEngine) color:[255,199,71] --RENDER ENGINE
gw.wText [10,210,0] ("FPS:   " + (frameRate as string)) color:[255,199,71] -- FPS
gw.wText [10,195,0] ("Units:    "  + units.SystemType) color:[255,199,71]	 --UNITS
gw.wText [10,180,0] tf color:white	 -- TOTAL FACES
gw.wText [10,165,0] sf color:white			-- SELECTED FACES
gw.wText [10,150,0] MaterialName color:green  --MATERIAL NAME
	
	
gw.updateScreen()
redrawViews()
)
registerRedrawViewsCallback MaterialStatistics




