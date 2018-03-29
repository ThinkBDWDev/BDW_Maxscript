/*HeaderStart*******************************************************
:Created By:			Rodri Garcia
:Company:				Rodri Garcia
:Site:					http://rgarcia-digitaldesign.com
:Email:				info@rgarcia-digitaldesign.com
:Client:				Think BDW
:Purpose:				Library Containing Variable Definitions & Functions Declarations

:History:
	V:0.00.01A 
		Getting started. 
:Todo:
:Bugs:
:Tests:
*******************************************************HeaderEnd*/
fn Users = 
(
UsersList = #()
UsersList = getdirectories @"\\CGISERVER\BDWRenderC\CGIRender\*"
UsersListUI = #()

for i =1 to UsersList.count do
	(
		UsersListUI[i] = (filterstring UsersList[i] @"\")[4]
	)

)	
/*
RenderDir = #()
RenderDir = getdirectories (@"\\CGISERVER\BDWRenderC\CGIRender\" + UsersListUI[3] + "\*")
RenderDirUI = #()	

for i = 1 to RenderDir.count do
	(
		RenderDirUI[i] = (filterstring RenderDir[i] @"\")[5]
	)	
*/
	
print UserListUI
-- Print RenderDirUI

mfn = maxfilename
mfp = maxfilepath


