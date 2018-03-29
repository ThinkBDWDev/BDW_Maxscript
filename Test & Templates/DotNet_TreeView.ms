 try(destroyDialog theRollout)catch()
rollout theRollout "The Rollout" width:300
(
local TreeNodeClass = dotnetclass "System.Windows.Forms.TreeNode"

dotNetControl tv "system.windows.forms.treeView" height:450

fn IsMatch str patternArr =
(
noMatch = true
for p in patternArr while noMatch where matchpattern str pattern:p do noMatch = false
NOT noMatch
)

fn GetDirectoryTree dir ignoreList:undefined =
(
flt = filterstring dir "\\"
dirName = flt[flt.count]

if ignoreList == undefined OR NOT IsMatch dirName ignoreList then
(
t = dotnetobject TreeNodeClass dirName
t.Tag = dir -- assign the full path to the tag property

subDirs = GetDirectories (dir+@"/*")
subNodes = #()
for d in subDirs do
(
sub = GetDirectoryTree d ignoreList:ignoreList
if sub != undefined do append subNodes sub
)
t.Nodes.AddRange subNodes

t
)
else
undefined
)

on theRollout open do
(
DIR = @"\\CGISERVER\BDWRenderC\CGIRender\Rodri\"
n = GetDirectoryTree (DIR) ignoreList:#("*maps*")
tv.Nodes.Add n
n.Expand()	-- expand the top node
)
)
createDialog theRollout