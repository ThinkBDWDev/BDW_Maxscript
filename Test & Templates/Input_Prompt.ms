
-- instantiate the object
theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" "Type in new name here"
theobj.text ="A terribly useful dotnet input dialog"
DialogResult = theObj.Showmodal()

--test if the ok button was pressed
dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)
--get the new text string
NewStringEntered = theobj.InstanceName