/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site: Collect Assets
:Email:
:Client:
:Purpose:
:History:V1

:Todo:     
:Bugs:

:Tests: 
*******************************************************HeaderEnd*/

struct AssetCollectTool

(

     fn SaveVersion FileSavePath: FileNameOutput: =
     (
          dir = dotNetClass "System.IO.Directory"
          files = dir.GetFiles(FileSavePath)
          FindFiles = for i in files where matchpattern i pattern: ("*" + FileNameOutput + "*") collect i

          file = FileSavePath + FileNameOutput +  "_" + FindFiles.count as String + ".max" 
          return file
          )

     )

--## UI ##
try(destroydialog AssetCollect) catch()

rollout AssetCollect "AssetCollect" width:200
(

     editText pathName "path"

     button SaveSEL "Export Assets" height:30
     progressBar Prog color: green height:10

     on SaveSEL pressed do
     (


          try (

               max create mode

               if pathName.text != "" then
               (	

               	disableSceneRedraw() 

                    Prog.value = 0

                    arr = #()

                    for o in selection where isValidNode o AND not isGroupMember o do
                    (
                         append arr o
                         )

                    for o = 1 to arr.count do
                    (
                         Prog.value = 100.*o/arr.count
                         arr[o].pivot = [arr[o].center.x,arr[o].center.y,arr[o].min.z]
                         orig_Pos = arr[o].position
                         arr[o].position = [0,0,0]

                         select arr[o]

                         SaveFileName = AssetCollectTool.SaveVersion FileSavePath:(pathName.text + "/")  FileNameOutput:arr[o].name
                         saveNodes $ (SaveFileName)

                         arr[o].position = orig_Pos

                         )

                    enableSceneRedraw()

                    )
               else (messageBox "no path defined!")

               )
          catch(messageBox "no path or objects selected!")

          )
     )
CreateDialog AssetCollect style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)