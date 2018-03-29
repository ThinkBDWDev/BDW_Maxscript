macroScript Jobfolder category:"BDW"  tooltip:"Job Folder" Icon:#("JobFolder",1)

(
EmptyPath = "//CGISERVER/BDWCGIWorkC/"
FileDirF = maxfilepath
if FileDirF == "" then sPath = shelllaunch Emptypath ""
	else
shelllaunch 	maxfilepath ""
)