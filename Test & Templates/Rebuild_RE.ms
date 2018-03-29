function setUpRenderElements =
				(  
					if renderSceneDialog.isopen() == true then renderSceneDialog.close()
					MainSavePath = getFileNamePath rendOutputFilename
					print MainSavePath
				 
					re = maxOps.GetCurRenderElementMgr()
					numb = re.numrenderelements() 
				 
					for i=0 to (numb-1) do
					(
						el = re.getrenderelement i
						currentFileName = (fileNameFromPath (re.GetRenderElementFileName i))
				--  		newDirectory = MainSavePath+"\\"+el.elementname
				-- 		if re.GetElementsActive() then makeDir newDirectory
							
						RelemName = (trimright rendOutputFilename ".exr")
						newFileName = RelemName + "_" + el.elementname +  ".exr"
						re.SetRenderElementFileName i newFileName 
					)
				)
				setUpRenderElements()
				renderSceneDialog.open()	