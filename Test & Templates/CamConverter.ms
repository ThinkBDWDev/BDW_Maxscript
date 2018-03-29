
MaxPath = maxfilepath
MaxName = (trimright maxfilename ".max")
originalname = maxfilename
NewMaxName = MaxName + "_2014.max"
NewMaxName2 = MaxName + "_2016Backup.max"

OldCams = for i in cameras where classof i == Physical collect i

if querybox "Save File before converting?" beep:true then
(
	saveMaxFile  originalname
)

for i =1 to OldCams.count do
	(
		if OldCams[i].targeted == true then
		(
			NewCam = vrayCreateVRayPhysicalCamera()
			NewCam.targeted = false
			NewCam.targeted = true
			NewCam.pos = OldCams[i].pos
			NewCam.target.pos = OldCams[i].target.pos
			
			
			NewCam.film_width = OldCams[i].film_width_mm
			NewCam.focal_length = OldCams[i].focal_length_mm
			NewCam.lens_tilt = OldCams[i].vertical_tilt_correction
			
			Hide OldCams[i]
		)
		
		else
		(
-- 			messagebox "Some Cameras couldn't be converted"
			NewCam2 = vrayCreateVRayPhysicalCamera()
			
			NewCam2.film_width = OldCams[i].film_width_mm
			NewCam2.focal_length = OldCams[i].focal_length_mm
			NewCam2.lens_tilt = OldCams[i].vertical_tilt_correction
			
			NewCam2.targeted = false
-- 			NewCam2.targeted = true
			
			NewCam2.rotation = OldCams[i].rotation
			NewCam2.pos = OldCams[i].pos
			
			Hide OldCams[i]
			
			
			
			OldCams[i]
			)
		
	)

	
OutputFile = (MaxPath + NewMaxName)
OutputFile2 = (MaxPath + NewMaxName2)
OldFolder = (MaxPath + "OLD" + @"\" + NewMaxName)
OldFolder2 = (MaxPath + "OLD" + @"\" + NewMaxName2)	
	
savemaxfile OutputFile2 useNewFile:false
	
delete OldCams

savemaxfile OutputFile saveAsVersion:2014
	
copyfile OutputFile OldFolder
copyfile OutputFile2 OldFolder2

deletefile OutputFile2
deletefile OutputFile
