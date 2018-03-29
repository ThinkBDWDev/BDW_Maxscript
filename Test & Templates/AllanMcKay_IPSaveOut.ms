/*
1.	Save max file for rendering
2. 	Save IL file
3.	Turn GI on
4.	Change GI settings
5.	Change render elements
6.	Change render output
7.	Fume containers non renderable

*/

-- Directory Locations
RootPath = "C:/temp/video2/"
myMaxFilePath = RootPath + "max"
BeautyRender = RootPath + "renders/Beauty"
ILRender = RootPath + "renders/IL"

-- Make Directories
MakeDir myMaxFilePath
MakeDir BeautyRender
MakeDir ILRender

MFN = (filterstring maxfilename ".")[1]

-- Save Beauty Max File
FileSaveOut = myMaxFilePath + "/" + MFN + "_beauty" + ".max"
savemaxfile FileSaveOut

-- Save Interactive Lighting Max File
FileSaveOut = myMaxFilePath + "/" + MFN + "_IL" + ".max"
savemaxfile FileSaveOut

renderSceneDialog.close()	-- Close render scene dialog to make changes
vr = renderers.current
vr.gi_on  = true
vr.gi_irradmap_preset = 2
vr.gi_primary_type = 0
vr.gi_primary_multiplier = 20
vr.gi_secondary_type = 3
vr.lightcache_subdivs = 1000
vr.lightcache_sampleSize  = .01
$*.material = (standardmaterial diffuse:[10,10,10] name:"blackShader")
$fume*.primaryVisibility = off

-- Set render output
RO = ILRender + "/" + mfn + "_ILPass_.exr"
rendoutputfilename = RO
rendTimeType = 3
RendStart = 0
RendEnd = animationrange.end
rendSaveFile  = true
