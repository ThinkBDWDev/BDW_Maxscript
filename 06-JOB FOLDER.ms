--macroScript Jobfolder category:"RG_Tools" tooltip:"Job Folder" Icon:#("JobFolder",1)

(
FileDirF = maxfilepath
if FileDirF == "" then sPath = getSavePath initialDir:"W:/"
	else
shelllaunch 	maxfilepath ""
)