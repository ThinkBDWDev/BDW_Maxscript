(
	local du = DeadlineUtil  --this is the interface exposed by the Lightning Plug-in which provides communication between Deadline and 3ds Max
	if du == undefined do  --if the script is not being run on Deadline (for testing purposes),
	(
		struct DeadlineUtilStruct   --define a stand-in struct with the same methods as the Lightning plug-in
		(
			fn SetTitle title = ( format "Title: %\n" title ),
			fn SetProgress percent = (true),
			fn FailRender msg = ( throw msg ),
			fn GetSubmitInfoEntry key = ( undefined ),
			fn GetSubmitInfoEntryElementCount key = ( 0 ),
			fn GetSubmitInfoEntryElement index key = ( undefined ),
			fn GetJobInfoEntry key = ( undefined ),
			fn GetAuxFilename index = ( undefined ),
			fn GetOutputFilename index = ( undefined ),
			fn LogMessage msg = ( format "%\n" msg ),
			fn WarnMessage msg = ( format "Warning: %\n" msg ),
			CurrentFrame = ((sliderTime as string) as integer),
			CurrentTask = ( -1 ),
			SceneFileName = ( maxFilePath + maxFileName ),
			SceneFilePath = ( maxFilePath ),
			JobsDataFolder = ( "" ),
			PluginsFolder = ( "" )
		)
		du = DeadlineUtilStruct() --create an instance of the stand-in struct
	)--end if
	
	du.SetTitle "MAXScript Job" --set the job title 
	du.LogMessage "Starting MAXScript Job..." --output a message to the log
	local st = timestamp() --get the current system time

	
	
 
 TempDir = ("C:\TEMP")
 Makedir TempDir
 isDirectoryWriteable TempDir	
	
user = sysInfo.username 
computer = sysInfo.computername 
TimeVar = (filterstring localtime " ")
Date = TimeVar[1] 
if computer == "BDWC177" then
	(user="Simon.Odds")
if computer == "BDWC176" then
	(user="user")
CMD = ("Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion| Format-Table �Wrap > C:\TEMP"  +  @"\" + "InstalledPrograms" + "__"  + "__" + computer + ".txt")
shelllaunch "Powershell.exe" CMD
global EmailBody = "Not Posible to check"
MaxVer = getFileVersion "$max/3dsmax.exe" -- Max Version and Service Pack
AEVer = getFileVersion @"C:\Program Files\Adobe\Adobe After Effects CC\Support Files\AfterFX.exe"
PsVer = getFileVersion @"C:\Program Files\Adobe\Adobe Photoshop CC (64 Bit)\Photoshop.exe"
AnimaPath = @"C:\aXYZ design\an(i)ma 1.0 64-bit"
AttachFile = ("C:\TEMP"  +  @"\" + "InstalledPrograms" + "__"  + "__" + computer + ".txt")
FileCheck =doesFileExist AnimaPath
if FileCheck == true then
(EmailBody = "Anima INSTALLED")
else(EmailBody = "Anima NOT Installed")
MailMessage = dotNetObject "System.Net.Mail.MailMessage"
MailAdressFrom = dotNetObject "System.Net.Mail.MailAddress"  "cgirenderfarm@gmail.com"
MailMessage.From = MailAdressFrom
MailAdressTo = dotNetObject "System.Net.Mail.MailAddress" "rodri.garcia@thinkbdw.co.uk"
MailAdressTo2 = dotNetObject "System.Net.Mail.MailAddress" "rodri.garcia.gomez@gmail.com"
MailMessage.To.Add MailAdressTo 
MailMessage.To.Add MailAdressTo2
MailMessage.Subject = (user + "       " +  computer + "       -       SoftwareList")
MailMessage.Body = ("AutoGenerated Email \n" + "     " + EmailBody + "           --------          " + computer)
MailAttachment = dotNetObject "System.Net.Mail.Attachment" AttachFile
MailMessage.Attachments.Add(MailAttachment)
Client = dotNetObject "System.Net.Mail.SmtpClient"
Client.Host = "smtp.gmail.com"

 Client.EnableSsl = true;
 NetworkCred = dotNetObject "System.Net.NetworkCredential"
 NetworkCred.UserName = "cgirenderfarm@gmail.com"
 NetworkCred.Password = "icciyciigvsgdqmw"
 Client.UseDefaultCredentials = true
 Client.Credentials = NetworkCred
 Client.Port = 587
 Client.Send MailMessage
 



	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--YOUR SCENE PROCESSING CODE GOES HERE
	
	
	
	du.LogMessage ("Finished MAXScript Job in "+ ((timestamp() - st)/1000.0) as string + " sec.") --output the job duration
	true  --return true if the task has finished successfully, return false to fail the task.
)--end script