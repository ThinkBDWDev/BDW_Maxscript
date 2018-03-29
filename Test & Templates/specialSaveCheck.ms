(
	global specialSaveCheck
	
	fn specialSaveCheck notifyValues=
	(
		if notifyValues != undefined do
		(
			autobakPath = GetDir #autoback
			currentSavePath = getFilenamePath notifyValues[2]
			
			-- check for autoback folder
			if currentSavePath == autobakPath OR (substring currentSavePath 1 (currentSavePath.count-1)) == autobakPath do
			(
				if queryBox "You should never save to your autobackup folder!\nWould you like to save to another folder?" caption:"Don't do this..." do
				(
					newSaveTry = getSaveFileName "" caption:"New try! Remember: don't select autoback folder!"
					if  newSaveTry != undefined do
					(
						saveMaxFile newSaveTry
					)
				)
			)
			
			-- backup existing file to prevent file corruption
			if notifyValues[1] == 1 AND doesFileExist (notifyValues[2]) do
			(
				specialBackupFile = (notifyValues[2] + "_bak")
				if doesFileExist specialBackupFile do deleteFile specialBackupFile
				renameFile (notifyValues[2]) specialBackupFile
			)
		)
	)
	
	callbacks.removeScripts id:#specialSaveCallback
	callbacks.addScript #filePreSaveProcess "(specialSaveCheck(callbacks.notificationParam()))" id:#specialSaveCallback
)