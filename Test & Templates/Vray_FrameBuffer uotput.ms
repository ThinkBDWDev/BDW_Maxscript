vr = renderers.current

fopenexr.SetCompression 7 
fopenexr.setSaveScanline false 
fopenexr.setSaveRegion false


TMP_filename = sysInfo.tempdir + "tmpFile.jpg"
BitM=Bitmap 10 10 fileName: TMP_filename
save BitM
close BitM
vr.output_splitbitmap=BitM
deleteFile TMP_filename



vr.output_on =true
vr.output_saveFile =true
-- vr.output_fileName = "true.exr"

vr.output_splitgbuffer =true
vr.output_splitfilename = @"D:\TEST_TGA.exr"

vr.output_getsetsfrommax =true
vr.output_splitRGB =true
vr.output_splitAlpha =true
vr.output_rawExrUseHalf =false


vr.lightcache_switchToSavedMap = false
vr.adv_irradmap_switchToSavedMap = false


vr.gi_primary_type = 2 -- Enable Brute Force

vr.dmcgi_subdivs = 16 -- BruteForce Samples
vr.imageSampler_shadingRate = 15
vr.dmc_useLocalSubdivs = false

vr.imageSampler_type_new = 0 -- Set Bucket Mode

vr.dmc_optimizeShadingRate = true -- ??????? 
vr.dmc_balance_subdivs  = true -- Enable Divide Shading Subdivs

vr.imageSampler_type = 0 -- OLD AA System Call
vr.adaptiveSubdivision_minRate = 2
vr.adaptiveSubdivision_maxRate = 25