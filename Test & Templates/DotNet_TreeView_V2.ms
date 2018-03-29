rollout theRollout "The Rollout" width:600
(
local TreeNodeClass = dotnetclass "System.Windows.Forms.TreeNode"

dotNetControl tv "system.windows.forms.treeView" height:750

fn GetDirectoryTree dir =
(
flt = filterstring dir "\\"
dirName = flt[flt.count]

t = dotnetobject TreeNodeClass dirName
t.Tag = dir -- assign the full path to the tag property

subDirs = GetDirectories (dir+@"/*")
subNodes = for d in subDirs collect GetDirectoryTree d
t.Nodes.AddRange subNodes

t
)

on theRollout open do
(
n = GetDirectoryTree (@"\\CGISERVER\BDWRenderC\CGIResources\3D NEW\")
tv.Nodes.Add n
)
)
createDialog theRollout