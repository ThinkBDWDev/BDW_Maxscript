
unRegisterRedrawViewsCallback showObjectNames

fn showObjectNames=
(
gw.setTransform(Matrix3 1)
for o in objects where not o.isHidden do
(
	
	if o != selection then(
	gw.text o.pos (o.name) color:yellow)
-- 	gw.text (o.pos+[0,-150,-2]) (o.pos as string) color:yellow
)
try(
	for i in selection do
	(
	gw.text i.pos (i.name) color:red
	)
	
	)
	
	catch()

gw.enlargeUpdateRect #whole
gw.updateScreen()
)
registerRedrawViewsCallback showObjectNames
-- showObjectNames()