rollout webbrowser_rollout "Web Test" width:1000 height:775
(
edittext edt_url "URL:" text:"https://1drv.ms/x/s!AmuhkEpt5uYxgsAXCGZLLl_2ZScjoA"
dotNetControl wb "System.Windows.forms.WebBrowser" pos:[10,22] width:980 height:755
fn openURL urlString = (
wb.url = dotNetObject "System.Uri" urlString )
on edt_url entered txt do openURL txt
on webbrowser_rollout open do openURL edt_url.text
)
createdialog webbrowser_rollout