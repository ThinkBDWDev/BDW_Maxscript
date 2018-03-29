clearlistener()
RootDir = #()
RootDir = getdirectories (@"\\CGISERVER\BDWRenderC\CGIRender\Rodri\*")
		
global RootDirUI = #()
for i =1 to RootDir.count do
	(
	RootDirUI[i] = (filterstring RootDir[i] @"\")[5]
	)
	
	
global ChildDirListUI = #()
global ChildDirList = #()
	
	
fn ChildExtractor PathInput =
(
	

ChildDirList = getdirectories (PathInput + "*")

for i =1 to ChildDirList.count do
	(
	ChildDirListUI[i] = (filterstring ChildDirList[i] @"\")[6]
	)	
	

)		





-- print TemArray


try(destroydialog FolderExplorer )catch()
	rollout FolderExplorer ""
	(

		listbox ParentL "Parents" items:RootDirUI
-- 		listbox ChildsL "Childs" items:ChildDirListUI
		subrollout subrolls "" height:140	
		
		rollout CC ""
			(	
				
				listbox ChildsL "Childs" items:ChildDirListUI
					on ChildsL selected P do
						(
							DestinationPath = ChildDirList[ChildsL.selection]
							print DestinationPath
-- 							print ChildsL.items
						)				
			)
		
		on ParentL selected O do
			(	
				PathInput = RootDir[ParentL.selection]
				ChildExtractor PathInput
				removeSubRollout  FolderExplorer.subrolls  CC
				AddSubRollout FolderExplorer.subrolls  CC
				FolderExplorer.subrolls.height = 400
				DestinationPath = ChildDirList[ParentL.selection]
				print DestinationPath
				ChildDirListUI = #()
				
				)

		
		
	)
	createdialog FolderExplorer width:200 height:555
	
	