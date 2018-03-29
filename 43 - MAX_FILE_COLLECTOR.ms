/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose:
:History:V1.0

:Todo: Ecpand to add relink function, progress bar etc..
		
:Bugs:
:Tests: 
*******************************************************HeaderEnd*/

/* 
add getSavePath() to pick pathbutton..


*/

function Batmax typefile: filepathMax: = 
(

type = "*" + "." + typefile
FilePath = filepathMax 

MaxFiles = getfiles (FilePath + "/" + type)

for i= 1 to MaxFiles.count do
(
	
FolderName = (trimright MaxFiles[i] type)
	
MaxOutput = FolderName
MakeDir MaxOutput

test = getMAXFileAssetMetadata MaxFiles[i] ---file

foundAssets =#()

  for fa=1 to test.count do 
  ( 
		
		fname = (getfilenamepath test[fa].filename + getfilenamefile test[fa].filename + getfilenametype test[fa].filename)
		append foundAssets fname
	
  )



--save out files
outputFolder = MaxOutput

	--TEST NEW LOOP FILE
	XrefFiles = #()
	for i=1 to foundAssets.count where matchpattern foundAssets[i] pattern: "*.max" do
	(
		test = getMAXFileAssetMetadata foundAssets[i]
		
		

		
	  for fa=1 to test.count do 
	  ( 
			
		fname = (getfilenamepath test[fa].filename + getfilenamefile test[fa].filename + getfilenametype test[fa].filename)
		append XrefFiles fname
		
	  )
		
	)
  
	for i=1 to foundAssets.count do
	(	
			copyfile foundAssets[i] (outputFolder + "/" +  getFilenameFile foundAssets[i] + getFilenameType foundAssets[i])
	)
	
	for i=1 to XrefFiles.count do
	(
		copyfile XrefFiles[i] (outputFolder + "/" +  getFilenameFile XrefFiles[i] + getFilenameType XrefFiles[i])
	)
		
)

)

try(destroydialog BatchCollectBDW) catch() 

rollout BatchCollectBDW "Tool" 
(
 editText BatchPath_txt "Max Files"
 button collectFiles "collect files"
 
 on collectFiles pressed do
 (
-- 		 try (
	 
	Batmax typefile:"max" filepathMax:BatchPath_txt.text
-- 		 )catch()
 )
 
) 
CreateDialog BatchCollectBDW