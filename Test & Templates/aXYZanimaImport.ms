
 animaisfound=false
 opencolladaisfound=-1
 for c=1 to importerPlugin.classes.count do
 (
	 mclass= importerPlugin.classes[c] as string
	 if mclass == "AnimaImport" then
		 animaisfound=true
	 if mclass == "OpenCOLLADAImporter" then
		 opencolladaisfound=c	 
 )
 
mpath=	systemTools.getEnvVariable("USERPROFILE")
mpath=mpath+"\\appdata\\Local\\an(i)ma\\export\\"
 
 if animaisfound==true then
	 fileToImport = getOpenFileName caption:"Import an(i)ma file" types:"an(i)ma Native file (*.ani)|*.ani|an(i)ma Collada file(*.dae)|*.dae|"  filename:mpath historyCategory:"an(i)ma"
 else
	 fileToImport = getOpenFileName caption:"Import an(i)ma file" types:"an(i)ma Collada file(*.dae)|*.dae|"   filename:mpath historyCategory:"an(i)ma"
 
if fileToImport !=undefined then
(
	if((matchpattern fileToImport pattern:"*.dae") and opencolladaisfound>0) then		
		ImportFile fileToImport #noPrompt
	else
		ImportFile fileToImport #noPrompt
	
	if((matchpattern fileToImport pattern:"*.ani")==true) then
	(
		
	    local thisscriptpath = getFilenamePath (getThisScriptFilename())
		FileIn (thisscriptpath+"AdaptAnimaMaterial.mse")
			
		local zoomAt=#()
			
		max select none
		select(for o in geometry where classOf o == AnimaObjectSubMesh collect o)
		max zoomext sel
	)
)
	
	
	