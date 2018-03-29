CheckName = #("Testt","LIBROS","Glass","Test","LIBROS")

for i = 1 to scenematerials.count do
(
Pattern = "*" + CheckName[i] + "*"
TempBitmap = scenematerials[i].texmap_diffuse
	if TempBitmap != undefined then
	(
		CheckPath = TempBitmap.fileName 
	)else(CheckPath = "Null")

Check = matchpattern CheckPath pattern:Pattern
Print Check
)








/*
CCC = "*" + CC + "*"
						
						
						LightsCam = (lights as array)
						
						for b in LightsCam  where matchpattern b.name pattern:CCC and classof b == VRaySun do