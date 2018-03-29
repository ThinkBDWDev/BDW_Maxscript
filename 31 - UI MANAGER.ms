/*
cui.getDir()
cui.getConfigFile()  
cui.setConfigFile "Path"
cui.saveConfigAs <filename_string> 
cui.loadConfig <filename_string> 
actionMan.loadKeyboardFile "KbdFile.kbd"  
actionMan.saveKeyboardFile "KbdFile.kbd" 
actionMan.getKeyboardFile() 

-- menuMan.loadMenuFile "MaxModelingMenu.mnu"
menuMan.getMenuFile()   
menuMan.loadMenuFile <filename>file
menuMan.saveMenuFile <filename>file 


menuMan.getMainMenuBar() 


\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\UI Files

*/


UsersList = #()
UsersList = getdirectories @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\UI Files\*"
-- UsersList = getdirectories @"\\192.168.0.16\CGI_Work\ThinkBDW\R&D\UI Loader\*"
	UsersListUI = #()
	for i =1 to UsersList.count do
		(
			UsersListUI[i] = (filterstring UsersList[i] @"\")[8]
			
			)



try(destroydialog UILoader )catch()
	rollout UILoader "UI Loader"
	(
		dropdownlist _User "User" items:UsersListUI
		checkbox Toolbars "Toolbars" checked:true pos:[10,50]
		checkbox Menus "Menus" checked:true pos:[10,65]
		checkbox Shortcuts "Shortcuts" checked:true pos:[10,80]
		button LoadUI "Load UI" pos:[100,50]
		button ExportUI "Export UI" pos:[90,75]
		
		
		on LoadUI pressed do
			(
				if Toolbars.checked then(
				try(
				CUIPath = #()
				CUIPath = getfiles (UsersList[_User.selection] + "*" +".cuix")
				cui.loadConfig CUIPath[1])catch())
				
				if Menus.checked then(
				try(
				MenuFile = #()
				MenuFile = getFiles (UsersList[_User.selection] + "*" +".mnux")
				menuMan.loadMenuFile MenuFile[1]
				)catch())
				
				if Shortcuts.checked then(
				try(
				KBFile = #()
				KBFile = getFiles (UsersList[_User.selection] + "*" +".kbdx")
				actionMan.loadKeyboardFile KBFile[1])catch())
			)
			
		on ExportUI pressed do
			(
				if querybox "Overwrite Existing UI Files from database?" beep:true then(
				if Toolbars.checked then(
				cui.saveConfigAs (UsersList[_User.selection] + _User.selected +".cuix"))
					
				if Menus.checked then(
				menuMan.saveMenuFile (UsersList[_User.selection] + _User.selected +".mnux"))
					
				if Shortcuts.checked then(
				actionMan.saveKeyboardFile (UsersList[_User.selection] + _User.selected +".kbdx"))
				)
			)
		
		
		
		
		on _User selected P do
			(
				print (UsersList[_User.selection])
				)
		
		
		
		
		
	)
	createdialog UILoader --width: height:





-- cui.loadConfig @"C:\Users\Rodri.Garcia\AppData\Local\Autodesk\3dsMax\2014 - 64bit\ENU\en-US\UI\Workspace1__usersave__.cuix" -- Load UI File