--macroScript RelinkBitmaps category:"RG_Tools" tooltip:"Log File" Icon:#("MaxLog",1)


theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" "Add Comment for this session"
theobj.text ="Text Input Dialog"
DialogResult = theObj.Showmodal()

dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)


cmm = theobj.InstanceName



FileName = maxfilename
TFileName = trimright FileName ".max"
FileDir = maxfilepath
FileSize = getFileSize (FileDir + FileName)
FileSizeF = (FileSize * 0.000001)
FileSMB = (FileSizeF as string) + "Mb"
user = sysInfo.username 
computer = sysInfo.computername 
date = LocalTime

outname = FileDir  + TFileName + "_" +"Logfile.txt"
uncpath = pathConfig.convertPathToUnc outname

if doesfileexist outname == false then 
(cf = createfile outname
	flush
	close cf
	--messagebox "Click again"
)

if doesfileexist outname then
(
fs = (openFile outname mode:"a+")


print "\n" to:fs
print "LOG ENTRY ADDED" to:fs
format "Filename       :%\n" Filename to:fs
-- print "\n" to:fs
format "File Directory :%\n" FileDir to:fs
format "File Size       :%\n " FileSMB to:fs
-- print "\n" to:fs
format "User           :%\n" User to:fs
-- print "\n" to:fs
format "Computer       :%\n" computer to:fs
-- print "\n" to:fs
format "Date           :%\n" date to:fs
--format "Comments       :%\n" cmm to:fs
Print "END OF LOG ENTRY" to:fs
print "\n" to:fs



-- print FileName to:fs
-- Print FileDir to:fs
-- Print User to:fs
-- Print computer to:fs
-- Print Date to:fs
	
close fs

)

outname
uncpath
