
rollout test "Test Timer"
(
label signalTime ""
label elapsedTime ""

local startTime
local myTimer = dotnetobject "System.Timers.Timer" 1000 autoreset:true

fn onElapsed sender args =
(
signalTime.text = args.SignalTime.ToString()
elapsedTime.text = (args.SignalTime.Subtract(startTime)).ToString()
)

on test open do
(
dotnet.AddEventHandler myTimer #elapsed onElapsed
startTime = (dotnetclass "datetime").now
myTimer.Start()
)

)
try (destroyDialog test) catch()
createDialog test