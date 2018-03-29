clearlistener()
RootDir = #()
RootDir = getdirectories (@"\\CGISERVER\BDWRenderC\CGIRender\Rodri\*")
		
global RootDirUI = #()
for i =1 to RootDir.count do
	(
	RootDirUI[i] = (filterstring RootDir[i] @"\")[5]
	)
	
	

global ChildDirList = #()
global CL2 = #()	
global TemArray = #()


for i=1 to InputPath.count do
	
	
	
	
	
	

-- fn ChildExtractor PathInput =
-- (
	
for i=1 to RootDir.count do
	(ChildDirList[i] = getdirectories (RootDir[i] + "*")
-- 	  print ChildDirList[i]
		)
		
for i = 1 to ChildDirList.count do
	(
		for b=1 to ChildDirList[i].count do
			(
				CL2[b] = ChildDirList[i][b]
				append TemArray CL2[b]

			)
	)
-- )		

-- ChildExtractor ChildDirList[1]	
Print TemArray	
	
	
	

-- ChildDirListUI = #()
-- for i =1 to ChildDirList.count do
-- 	(
-- 	ChildDirListUI[i] = (filterstring ChildDirList[i] @"\")[6]
-- 	)	



	/*
	
try(destroydialog FolderExplorer )catch()
	rollout FolderExplorer ""
	(

		listbox ParentL "Parents" items:RootDirUI
		listbox ChildsL "Childs" items:ChildDirListUI
-- 		subrollout subrolls "" height:14o		
			
		on ParentL selected O do
			(
			print RootDir[O]
			SearchDIR = RootDir[O]
			)
			
		ChildExtractor SearchDIR
		
	)
	createdialog FolderExplorer--width: height:
	
-- 	AddSubRollout FolderExplorer.subrolls  CC


-- for i=1 to ChildDirList.count do
-- 	(print ("-------------" + (i as string)+ "---------------")
-- print ChildDirList[i])