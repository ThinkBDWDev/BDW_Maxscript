struct myCoolDialogs
(
labelStr,

stringQuery = rollout stringQuery "Path Input"
(
local returnStr

label lblHeader
editText etInput

fn launch label: =
(
destroyDialog myCoolDialogs.stringQuery
if label != unsupplied then
myCoolDialogs.labelStr = label
else myCoolDialogs.labelStr = "Enter some text:"
createDialog myCoolDialogs.stringQuery modal:true
returnStr -- only put it here if the dialog is modal
)

on stringQuery open do
(
lblHeader.text = myCoolDialogs.labelStr
setFocus etInput
)

on etInput entered str do
(
destroyDialog myCoolDialogs.stringQuery
returnStr = str
)
)
)

myCoolDialogs = myCoolDialogs() -- as there are variables, an instance is needed
result = myCoolDialogs.stringQuery.launch label:"Path Input"

format "Returned String: %\n" result