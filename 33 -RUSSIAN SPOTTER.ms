

clearlistener()
INIFILE = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Rusian.txt"

-- RusChars = getINISetting INIFILE "symbols" "russ" as array

fo = (openFile INIFILE mode:"r")
LineRead = readLine fo
close fo

RusChars = #()

for i=1 to LineRead.count do
(
	
	RusChars[i] = LineRead[i]
	
	)

TabName = "Russian Characters"
if sme.GetViewbyname "Russian Characters" == 0 then(
sme.CreateView TabName
)
viewindex = sme.GetViewByName TabName
NewView = sme.GetView(viewindex)
	




-- RusChars = #("?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","À","Á","Â","Ã","Ä","Å","Æ","Ç","È","É","Ê","Ë","Ì","Í","Î","Ï","Ð","Ñ","Ò","Ó","Ô","Õ","Ö","×","Ø","Ù","Ú","Û","Ü","Ý","Þ","ß","à","á","â","ã","ä","å","æ","ç","è","é","ê","ë","ì","í","î","ï","ð","ñ","ò","ó","ô","õ","ö","÷","ø","ù","ú","û","ü","ý","þ","ÿ","¿","º","¸","´","³","¯","ª","¨","¥")



Assets = getclassinstances bitmaptexture
AssetsFileNames = #()
FaultyBitmaps = #()

for i=1 to Assets.count do
	(
		AssetsFileNames[i] = Assets[i].filename
	)
	
	
	
for i=1 to AssetsFileNames.count do
(
	if AssetsFileNames[i] != undefined then
		(mm
			for b =1 to RusChars.count do
			(
				CharToken = "*" + RusChars[b] + "*"
				if matchpattern AssetsFileNames[i] pattern:CharToken ignoreCase:true then 
				(
				appendIfUnique FaultyBitmaps AssetsFileNames[i]
				)
			)
		)
)
-- print FaultyBitmaps








if FaultyBitmaps.count != 0 do
(
	MSG = "Do you speak RUSSIAN?? Our render farm either...FIX IT"
	messagebox MSG)
	

CollectedBitmaps = #()	
	
for i=1 to AssetsFileNames.count do
(
	if AssetsFileNames[i] != undefined then
		(
			for b =1 to FaultyBitmaps.count do
			(
				PathToken = FaultyBitmaps[b]
				if matchpattern AssetsFileNames[i] pattern:PathToken ignoreCase:true then 
				(
				appendIfUnique  CollectedBitmaps Assets[i]
				)
			)
		)
)


TabName = "Russian Characters"
if sme.GetViewbyname "Russian Characters" == 0 then(
sme.CreateView TabName
)
viewindex = sme.GetViewByName TabName
NewView = sme.GetView(viewindex)
	


	
for i=1 to CollectedBitmaps.count do
(

NewView.CreateNode CollectedBitmaps[i][0,(0+(i*100))]

)

try(sme.Open())catch()	
	
	
for i=1 to FaultyBitmaps.count do
(
format "Invalid Characters in ------- %\n" FaultyBitmaps[i]
)














	